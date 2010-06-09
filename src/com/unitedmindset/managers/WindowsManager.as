package com.unitedmindset.managers
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.containers.TitleWindow;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	import mx.utils.ObjectUtil;
	import com.unitedmindset.events.WindowsManagerEvent;
	
	/**
	 * Fired when a window is shown.
	 */
	[Event(name="showWindowEvent",type="com.unitedmindset.events.WindowsManagerEvent")]
	/**
	 * Fired when a window is hidden/removed.
	 */
	[Event(name="hideWindowEvent",type="com.unitedmindset.events.WindowsManagerEvent")]
	/**
	 * Fired when you enable windows - set <code>enableWindows = true</code>.
	 */
	[Event(name="enableWindowsEvent",type="com.unitedmindset.events.WindowsManagerEvent")]
	/**
	 * Fired when you disable windows - set <code>enableWindows = false</code>.
	 */
	[Event(name="disableWindowsEvent",type="com.unitedmindset.events.WindowsManagerEvent")]
	
	/**
	 * Windows Manager that only allows one instance of a window at a time.
	 * */
	public class WindowsManager extends EventDispatcher {
		
		private static var _instance:WindowsManager;
		
		private var _windowsDictionary:Dictionary;
		
		private var _application:Object;
		
		//positions
		public static const POSITION_CENTER:String = "positionCenter";
		
		public static const POSITION_RELATIVE_FROM_MOUSE_EVENT:String = "positionRelativeFromMouseEvent";
		
		public static const POSITION_ABSOLUTE:String = "positionAbsolute";
		
		//settings
		
		private var _enableWindows:Boolean = true;
		
		/**
		 * Enable or disable global windows.
		 *
		 * @default true
		 * */
		public function get enableWindows():Boolean {
			return _enableWindows;
		}
		
		public function set enableWindows(value:Boolean):void {
			_enableWindows = value;
			
			if(value)
				dispatchEvent(new WindowsManagerEvent(WindowsManagerEvent.ENABLE_WINDOWS_EVENT));
			else
				dispatchEvent(new WindowsManagerEvent(WindowsManagerEvent.DISABLE_WINDOWS_EVENT));
		}
		
		//-------------------------
		//
		// Constructor
		//
		//-------------------------
		
		public function WindowsManager(enforcer:SingletonEnforcer) {
			this._initializeConstructor();
		}
		
		//added to play nice with the JIT compiler
		private function _initializeConstructor():void {
			this._windowsDictionary = new Dictionary();
			this._application = FlexGlobals.topLevelApplication;
		}
		
		static public function getInstance():WindowsManager {
			if(WindowsManager._instance == null) {
				WindowsManager._instance = new WindowsManager(new SingletonEnforcer());
			}
			return WindowsManager._instance;
		}
		
		//-------------------------
		//
		// Methods
		//
		//-------------------------
		/**
		 * Opens a window of a specific class with common additional close options.
		 *
		 * @param window
		 * @param modal Flag to determine modality.
		 * @param closeOnCloseButton
		 * @param closeOnMouseDownOutside
		 * @param position
		 * @param xOffset
		 * @param yOffset
		 * @param event
		 * @param title
		 * @param width
		 * @param height
		 * @param data
		 * @param args listener string and function pairs
		 *
		 */
		public function showWindow(window:Class, modal:Boolean = true, closeOnCloseButton:Boolean = false, closeOnMouseDownOutside:Boolean = false, position:String = POSITION_CENTER, xOffset:int = 0, yOffset:int = 0, event:MouseEvent = null, title:String = null, width:Object = null, height:Object = null, data:Object = null, ... args):void {
			var windowObject:Object = ObjectUtil.getClassInfo(window);
			
			if(_windowsDictionary[windowObject.name] == null && enableWindows && _application) {
				var createdWindow:IFlexDisplayObject = IFlexDisplayObject(PopUpManager.createPopUp(_application as DisplayObject, window, modal, PopUpManagerChildList.POPUP));
				//positioning
				switch(position) {
					case POSITION_RELATIVE_FROM_MOUSE_EVENT:
						if(event) {
							createdWindow.x = event.stageX + xOffset;
							createdWindow.y = event.stageY + yOffset;
						}
						break;
					case POSITION_ABSOLUTE:
						createdWindow.x = xOffset;
						createdWindow.y = yOffset;
						break;
					case POSITION_CENTER:
					default:
						createdWindow.addEventListener(FlexEvent.CREATION_COMPLETE, _onWindowCreationComplete);
						break;
				}
				//add listeners
				var i:int = 0;
				
				while(i < args.length) {
					createdWindow.addEventListener(args[i], args[i + 1]);
					i = i + 2;
				}
				_windowsDictionary[windowObject.name + "-args"] = args;
				
				if(createdWindow is TitleWindow) {
					if(closeOnCloseButton) {
						TitleWindow(createdWindow).showCloseButton = true;
						TitleWindow(createdWindow).addEventListener(CloseEvent.CLOSE, _removeWindowOnClose);
					}
					
					if(title)
						TitleWindow(createdWindow).title = title;
				}
				
				if(Object(createdWindow).hasOwnProperty("data") && data != null)
					Object(createdWindow).data = data;
				
				if(closeOnMouseDownOutside)
					createdWindow.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, _removeWindowOnMouseDownOutside);
				
				if(createdWindow is UIComponent) {
					if(width) {
						var foundPercentWidth:int = width.indexOf("%");
						
						if(foundPercentWidth > -1)
							UIComponent(createdWindow).percentWidth = int(width.replace("%", ""));
						else
							createdWindow.width = int(width);
					}
					
					if(height) {
						var foundPercentHeight:int = height.indexOf("%");
						
						if(foundPercentHeight > -1)
							UIComponent(createdWindow).percentHeight = int(height.replace("%", ""));
						else
							createdWindow.height = int(height);
					}
				}
				_windowsDictionary[windowObject.name] = createdWindow;
				dispatchEvent(new WindowsManagerEvent(WindowsManagerEvent.SHOW_WINDOW_EVENT, false, false, createdWindow, windowObject.name));
			}
		}
		
		/**
		 * @private
		 * on window creation complete
		 * */
		private function _onWindowCreationComplete(event:FlexEvent):void {
			var window:IFlexDisplayObject = IFlexDisplayObject(event.target)
			window.removeEventListener(FlexEvent.CREATION_COMPLETE, _onWindowCreationComplete);
			PopUpManager.centerPopUp(window);
		}
		
		/**
		 * @private
		 * removes the window on mouse down outside
		 * */
		private function _removeWindowOnMouseDownOutside(event:FlexMouseEvent):void {
			var window:IFlexDisplayObject = IFlexDisplayObject(event.target);
			window.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, _removeWindowOnMouseDownOutside);
			_hideWindowAutomatic(window);
		}
		
		/**
		 * @private
		 * removes the window on close
		 * */
		private function _removeWindowOnClose(event:CloseEvent):void {
			var window:IFlexDisplayObject = IFlexDisplayObject(event.target);
			window.removeEventListener(CloseEvent.CLOSE, _removeWindowOnClose);
			_hideWindowAutomatic(window);
		}
		
		/**
		 * @private
		 * Removes a window of a specific type
		 * */
		private function _hideWindowAutomatic(window:IFlexDisplayObject):void {
			var windowObject:Object = ObjectUtil.getClassInfo(window);
			_actuallyRemoveWindow(windowObject);
		}
		
		/**
		 * Removes a window of a specific type
		 * */
		public function hideWindow(window:Class):void {
			var windowObject:Object = ObjectUtil.getClassInfo(window);
			_actuallyRemoveWindow(windowObject);
		}
		
		/**
		 * Actually removes the window
		 * @param windowObject
		 *
		 */
		private function _actuallyRemoveWindow(windowObject:Object):void {
			if(this._windowsDictionary[windowObject.name] != null) {
				var window:IFlexDisplayObject = IFlexDisplayObject(_windowsDictionary[windowObject.name]);
				//args removal
				var i:int = 0;
				var a:Array = _windowsDictionary[windowObject.name + "-args"] as Array;
				
				if(a && a.length > 0) {
					while(i < a.length) {
						window.removeEventListener(a[i], a[i + 1]);
						i = i + 2;
					}
				}
				PopUpManager.removePopUp(window);
				delete _windowsDictionary[windowObject.name];
				delete _windowsDictionary[windowObject.name + "-args"];
				dispatchEvent(new WindowsManagerEvent(WindowsManagerEvent.HIDE_WINDOW_EVENT, false, false, window, windowObject.name));
			}
			windowObject = null;
		}
		
		public function getWindow(window:Class):IFlexDisplayObject {
			var windowObject:Object = ObjectUtil.getClassInfo(window);
			
			if(_windowsDictionary[windowObject.name] != null)
				return _windowsDictionary[windowObject.name] as IFlexDisplayObject;
			return null;
		}
	
	}
}
/**
 * Singleton Enforcer. 
 * @author jonbcampos
 * 
 */
class SingletonEnforcer {}