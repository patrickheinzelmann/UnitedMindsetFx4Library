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
package com.unitedmindset.events
{
	import flash.events.Event;
	
	/**
	 * Event triggered by Code Manager.
	 * 
	 * @author jonbcampos and john guerena
	 * 
	 * @see com.unitedmindset.managers.codemanager.CodeManager
	 */	
	public class CodeManagerEvent extends Event
	{
		//static consts
		public static const CODE_SUCCESSFUL:String = "codeSuccessful";
		
		private var _code:Array;
		public function get code():Array
		{
			return _code;
		}
		
		private var _originalCode:Array;
		public function get originalCode():Array
		{
			return _originalCode;
		}
		
		private var _caseSensitive:Boolean;
		public function get caseSensitive():Boolean
		{
			return _caseSensitive;
		}
		
		public function CodeManagerEvent(type:String, code:Array, originalCode:Array, caseSensitive:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_code = code;
			_originalCode = originalCode;
			_caseSensitive = caseSensitive;
		}
		
		override public function clone() : Event
		{
			return new CodeManagerEvent(type,code,originalCode,caseSensitive,bubbles,cancelable);
		}
	}
}