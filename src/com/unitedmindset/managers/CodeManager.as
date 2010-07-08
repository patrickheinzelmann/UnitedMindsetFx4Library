/*
Copyright (c) 2010. UnitedMindset
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are not permitted without 
explicit written consent from UnitedMindset:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the 
following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of UnitedMindset nor the names of its contributors may be used to endorse or 
promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

@ignore
*/
package com.unitedmindset.managers
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import com.unitedmindset.events.CodeManagerEvent;

	/**
	 * Fired when code successful.
	 */
	[Event(name="codeSuccessful",type="com.unitedmindset.events.CodeManagerEvent")]
	
	/**
	 * Manager Singleton for application wide codes. Great for easter eggs. 
	 * Preloaded with the <code>Konami Code</code>.
	 * 
	 * <p>There are a few options as to how to set up your code.
	 * <ul>
	 * <li>Enter in a string that you would want the user to type via the <code>stringCode</code> property. 
	 * The string will automatically be translated to keyboard code events for you.</li>
	 * <li>Enter in an array of mixed strings and keyboard codes (<code>Keyboard</code> constants work fine) entered via the <code>code</code> property. 
	 * The strings will automatically be translated to keyboard code events for you.</li>
	 * </ul>
	 * </p>
	 * 
	 * @author jonbcampos and john guerena
	 * 
	 */
	public class CodeManager extends EventDispatcher
	{
		//private vars
		private var _code:Array;
		private var _originalCode:Array;
		private var _keyStrokes:Array;
		private var _caseSensitive:Boolean = false;
		
		/**
		 * Singleton Enforced Constructor. 
		 * @param enforcer
		 * @param target
		 * 
		 */		
		public function CodeManager(enforcer:SingletonEnforcer,target:IEventDispatcher=null)
		{
			super(target);
			_keyStrokes = new Array();
			code = [Keyboard.UP,Keyboard.UP,Keyboard.DOWN,Keyboard.DOWN,Keyboard.LEFT,Keyboard.RIGHT,Keyboard.LEFT,Keyboard.RIGHT,66,65,Keyboard.ENTER];
			var app:Object = FlexGlobals.topLevelApplication;
			if(app.stage)
				registerEventListeners(new FlexEvent(FlexEvent.APPLICATION_COMPLETE));
			else
				app.addEventListener(FlexEvent.APPLICATION_COMPLETE,registerEventListeners);
		}
		
		static private var _instance:CodeManager;
		/**
		 * Retrieves an instance of the Code Manager Singleton Object. 
		 * @param target
		 * @return 
		 * 
		 */		
		public static function getInstance(target:IEventDispatcher=null):CodeManager
		{
			if(CodeManager._instance==null)
				CodeManager._instance = new CodeManager(new SingletonEnforcer(),target);
			return CodeManager._instance;
		}
		
		/**
		 * @private
		 * Registers Event Listeners. 
		 * @param event
		 * 
		 */		
		private function registerEventListeners(event:FlexEvent):void
		{
			var app:Object = FlexGlobals.topLevelApplication;
			var stage:Stage = app.stage as Stage;
			stage.focus = app as InteractiveObject;
			stage.addEventListener(KeyboardEvent.KEY_UP,onKeyBoardUp,false,0,true);
		}
		/**
		 * @private 
		 * Handles keyboard up event.
		 * @param event
		 * 
		 */		
		private function onKeyBoardUp(event:KeyboardEvent):void
		{
			//don't check if there is no code
			if(!_code||_code.length==0)
				return;
			//add new keystroke
			_keyStrokes.push(new CodeKey(event.keyCode));
			//get lengths
			var kL:int = _keyStrokes.length;
			var cL:int = _code.length; 
			//if longer than code, shift off first
			if(cL<kL){
				var diff:int = kL-cL;
				_keyStrokes.splice(0,diff);
				kL = _keyStrokes.length;
			}
			//code and keystroke must be same length to be correct
			if(cL!=kL)
				return;
			//check code
			var i:int=-1;
			while(++i<cL)
			{
				var keyStrokesTest:CodeKey = _keyStrokes[i] as CodeKey;
				if(_code[i]!=keyStrokesTest.keyCode)
					return;
			}
			//code in time check
			if(codeInTime>0){
				var first:CodeKey = _keyStrokes[0] as CodeKey;
				var last:CodeKey = _keyStrokes[_keyStrokes.length-1] as CodeKey;
				var difference:Number = last.time - first.time;
				if(difference>codeInTime)
					return;
			}
			
			//if you made it here they match
			dispatchEvent(new CodeManagerEvent(CodeManagerEvent.CODE_SUCCESSFUL,_code,_originalCode,_caseSensitive));
		}
		
		/**
		 * The code to match in keyCode format. 
		 * @return 
		 * 
		 */		
		public function get code():Array
		{
			return _code.slice();
		}
		
		public function set code(value:Array):void
		{
			if(!value)
				return;
			//store copy of original code
			_originalCode = value;
			//clear out old keystrokes
			_keyStrokes = new Array();
			var i:int = -1;
			var length:int = value.length;
			_code = new Array();
			while(++i<length)
			{
				//if string
				if(value[i] is String){
					var string:String = value[i] as String;
					var stringLength:int = string.length;
					var stringI:int = -1;
					while(++stringI<stringLength)
						_code = _code.concat(getKeyCodeForString(string.charAt(stringI)));
				//if uint
				} else if(value[i] is uint){
					_code.push(value[i]);
				//if number
				} else if(value[i] is Number){
					var nstring:String = Number(value[i]).toString();
					var nstringLength:int = nstring.length;
					var nstringI:int = -1;
					while(++nstringI<nstringLength)
						_code = _code.concat(getKeyCodeForString(nstring.charAt(nstringI)));
				}
				//anything else such as objects are rejected
			}
		}
		/**
		 * @private 
		 * Retrieves the character code for a string based on caseSensitivity flag.
		 * @param char
		 * @return 
		 * 
		 */		
		private function getKeyCodeForString(char:String):Array
		{
			var c:String;
			c = char.toUpperCase();
			if(caseSensitive){
				if(c == char)
					return [Keyboard.SHIFT,c.charCodeAt()];
				else
					return [c.charCodeAt()];
			} else {
				return [c.charCodeAt()]
			}
			return null;
		}
		
		/**
		 * Ability to set a string and have it transfered into keyCode. 
		 * @param value
		 * 
		 */		
		public function set stringCode(value:String):void
		{
			code = value.split();
		}
		
		/**
		 * @private
		 * 
		 * <p>If the <code>caseSensitive</code> flag is <i>true</i> then the user will have to hit the <i>shift</i> key prior to each uppercased letter.<br />
		 * Example 1:<br />
		 * Your code is: <i>Hello World</i>.<br />
		 * The user would have to press: <code><i>shift</i>, 'h', 'e', 'l', 'l', 'o', ' ', <i>shift</i>, 'w', 'o', 'r', 'l', 'd'</code>.<br /><br />
		 * Example 2:<br />
		 * Your code is: <i>HELLO</i>.<br />
		 * The user would have to press: <code><i>shift</i>, 'h', <i>shift</i>, 'e', <i>shift</i>, 'l', <i>shift</i>, 'l', <i>shift</i>, 'o'</code>.<br /><br />
		 * If the <code>caseSensitive</code> flag is <i>false</i> then the user will only have to press the <i>shift</i> key 
		 * when it is part of the code><br />
		 * Example 1:<br />
		 * Your code is: <i>Hello World</i>.<br />
		 * The user would have to press: 'h', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd'</code>.<br /><br />
		 * Example 2:<br />
		 * Your code is: <i>HELLO</i>.<br />
		 * The user would have to press: <code>'h', 'e', 'l', 'l', 'o'</code>.<br /><br />
		 * Example 3:<br />
		 * Your code is: <i>hello,Keyboard.SHIFT,Keyboard.UP,Keyboard.DOWN</i>.<br />
		 * The user would have to press: <code>'h', 'e', 'l', 'l', 'o', <i>shift</i>, <i>up arrow</i>, <i>down arrow</i></code>.<br /><br />
		 * </p>
		 * 
		 * @return 
		 * 
		 */		
		
		/**
		 * Case Sensitivity Flag. At anytime you can change your code to being case sensitive by making this flag <i>true</i>.
		 * @return 
		 */		
		public function get caseSensitive():Boolean
		{
			return _caseSensitive;
		}
		public function set caseSensitive(value:Boolean):void
		{
			//don't make a change if the value is same
			if(_caseSensitive!=value){
				_caseSensitive = value;
				code = _originalCode;
			}
		}
		
		private var _codeInTime:Number = -1;
		/**
		 * Time to enter code within, in milliseconds. 
		 * A value less than or equal to zero makes it so there is no time check.
		 * @return 
		 * 
		 */		
		public function get codeInTime():Number
		{
			return _codeInTime;
		}
		public function set codeInTime(value:Number):void
		{
			_codeInTime = value;
		}
	}
}
/**
 * Singleton Enforcer. 
 * @author jonbcampos
 * 
 */
class SingletonEnforcer{}
/**
 * Key Code for Code Manager.
 * @author jonbcampos
 * 
 */
class CodeKey{
	/**
	 * Constructor that also sets time. 
	 * @param keyCode
	 * 
	 */	
	public function CodeKey(keyCode:uint)
	{
		_keyCode = keyCode;
		var d:Date = new Date();
		_time = d.time;
	}
	
	private var _keyCode:uint;
	private var _time:Number;
	/**
	 * Key Code. 
	 * @return 
	 * 
	 */	
	public function get keyCode():uint
	{
		return _keyCode;
	}
	/**
	 * Time key was entered. 
	 * @return 
	 * 
	 */	
	public function get time():Number
	{
		return _time;
	}
}