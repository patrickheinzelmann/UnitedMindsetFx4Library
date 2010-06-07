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