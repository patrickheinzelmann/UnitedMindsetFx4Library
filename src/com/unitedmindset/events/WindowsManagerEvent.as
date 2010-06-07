package com.unitedmindset.events
{
	import flash.events.Event;
	
	import mx.core.IFlexDisplayObject;
	
	/**
	 * Event for WindowsManager 
	 * @author Administrator
	 * 
	 * @see com.mmillerassociates.managers.WindowsManager
	 */	
	public class WindowsManagerEvent extends Event
	{
		public static const SHOW_WINDOW_EVENT:String = "showWindowEvent";
		public static const HIDE_WINDOW_EVENT:String = "hideWindowEvent";
		public static const ENABLE_WINDOWS_EVENT:String = "enableWindowsEvent";
		public static const DISABLE_WINDOWS_EVENT:String = "disableWindowsEvent";
		
		private var _window:IFlexDisplayObject;
		/**
		 * Retrieves the related window object.
		 * @return window
		 * 
		 */		
		public function get window():IFlexDisplayObject
		{
			return _window;
		}
		
		private var _windowName:String;
		/**
		 * Retrieves the related window's name.
		 * @return name
		 * 
		 */		
		public function get windowName():String
		{
			return _windowName;
		}
		
		public function WindowsManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, window:IFlexDisplayObject=null, windowName:String=null)
		{
			super(type, bubbles, cancelable);
			_window = window;
			_windowName = _windowName;
		}
		
		override public function clone():Event
		{
			return new WindowsManagerEvent(type, bubbles, cancelable, window, windowName)
		}
		
	}
}