package com.unitedmindset.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.events.TextOperationEvent;
	
	[Event(name="promptChange",type="flash.events.Event")]
	
	[SkinState("normalAndPrompted")]
	[SkinState("disabledAndPrompted")]
	
	public class PromptingTextInput extends TextInput
	{
		public static const PROMPT_CHANGE_EVENT:String = "promptChange";
		
		public function PromptingTextInput()
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