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
package com.unitedmindset.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;
	
	/**
	 * Fired when the prompt changes. 
	 */	
	[Event(name="promptChange",type="flash.events.Event")]
	
	[SkinState("normalAndPrompted")]
	[SkinState("disabledAndPrompted")]
	
	/**
	 * TextArea with Prompt ability. 
	 * @author jonbcampos
	 * 
	 */
	public class PromptingTextArea extends TextArea
	{
		public static const PROMPT_CHANGE_EVENT:String = "promptChange";
		
		public function PromptingTextArea()
		{
			super();
			addEventListener(FlexEvent.INITIALIZE, _onInitialize);
		}
		
		//---------------------------------------------------------------------
		//
		//   Private Properties
		//
		//---------------------------------------------------------------------
		private var _textEmpty:Boolean = true;
		private var _displayAsPassword:Boolean = false;
		//---------------------------------------------------------------------
		//
		//   Public Properties
		//
		//---------------------------------------------------------------------
		
		//-----------------------------
		//  prompt
		//-----------------------------
		private var _prompt:String = "";
		private var _promptChanged:Boolean = false;
		
		[Bindable(event="promptChange")]
		/**
		 * Prompt to show when no text exists.
		 */		
		public function get prompt():String
		{
			return _prompt;
		}
		
		public function set prompt(value:String):void
		{
			if (_prompt != value) {
				_prompt = value;
				_promptChanged = true;
				dispatchEvent(new Event(PROMPT_CHANGE_EVENT));
				invalidateProperties();
			}
		}
		
		//-----------------------------
		//  displayAsPassword
		//-----------------------------
		override public function get displayAsPassword():Boolean
		{
			return _displayAsPassword;
		}
		
		override public function set displayAsPassword(value:Boolean):void
		{
			_displayAsPassword = value;
			super.displayAsPassword = value;
		}
		
		//-----------------------------
		//  text
		//-----------------------------
		override public function get text():String
		{
			if(_textEmpty)
				return "";
			else
				return super.text;
		}
		
		[Bindable("textChanged")]
		[CollapseWhiteSpace]
		[NonCommittingChangeEvent("change")]
		override public function set text(value:String):void
		{
			_textEmpty = (!value) || value.length == 0;
			super.text = value;
		}
		//---------------------------------------------------------------------
		//
		//   Override Methods
		//
		//---------------------------------------------------------------------
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == textDisplay)
			{
				textDisplay.addEventListener(FocusEvent.FOCUS_IN, _onTextDisplay_FocusIn);
				textDisplay.addEventListener(FocusEvent.FOCUS_OUT, _onTextDisplay_FocusOut);
				textDisplay.addEventListener(TextOperationEvent.CHANGE, _onTextDisplay_ChangeEvent);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if(instance == textDisplay)
			{
				textDisplay.removeEventListener(FocusEvent.FOCUS_IN, _onTextDisplay_FocusIn);
				textDisplay.removeEventListener(FocusEvent.FOCUS_OUT, _onTextDisplay_FocusOut);
				textDisplay.removeEventListener(TextOperationEvent.CHANGE, _onTextDisplay_ChangeEvent);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(_promptChanged)
			{
				_promptChanged = false;
				if(_textEmpty)
				{
					super.displayAsPassword = false;
					textDisplay.text = prompt;
					invalidateSkinState();
				}
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			if(_textEmpty)
				return super.getCurrentSkinState()+"AndPrompted";
			else
				return super.getCurrentSkinState();
		}
		//---------------------------------------------------------------------
		//
		//   Public Methods
		//
		//---------------------------------------------------------------------
		
		//---------------------------------------------------------------------
		//
		//   Private Methods
		//
		//---------------------------------------------------------------------
		
		//---------------------------------------------------------------------
		//
		//   Handler Methods
		//
		//---------------------------------------------------------------------
		/**
		 * @private
		 */
		private function _onInitialize(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.INITIALIZE, _onInitialize);
			
		}
		
		/**
		 * @private
		 */
		private function _onTextDisplay_FocusIn(event:FocusEvent):void
		{
			if(_textEmpty)
			{
				displayAsPassword = _displayAsPassword;
				text = "";
				invalidateSkinState();
			}
		}
		
		/**
		 * @private
		 */
		private function _onTextDisplay_FocusOut(event:FocusEvent):void
		{
			if(_textEmpty)
			{
				super.displayAsPassword = false;
				textDisplay.text = prompt;
				invalidateSkinState();
			}
		}
		
		/**
		 * @private
		 */		
		private function _onTextDisplay_ChangeEvent(event:TextOperationEvent):void
		{
			_textEmpty = super.text.length == 0;
			invalidateSkinState();
		}
	}
}