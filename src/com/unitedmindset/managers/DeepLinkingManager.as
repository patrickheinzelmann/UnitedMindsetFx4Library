package com.unitedmindset.managers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.ViewStack;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.BrowserChangeEvent;
	import mx.events.FlexEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.states.State;
	import mx.utils.OnDemandEventDispatcher;
	import mx.utils.URLUtil;
	import mx.validators.EmailValidator;
	
	/**
	 * Deep Linking Manager to help speed up Deep Linking in
	 * Flex Applications.
	 * 
	 * <p>
	 * All you have to do is register your uicomponents and
	 * tell the application when to update the url. That's it.
	 * </p>
	 * 
	 * @author jonbcampos
	 * 
	 */	
	public class DeepLinkingManager
	{
		//---------------------------------------------------------------------
		//
		//  Singleton Constructor
		//
		//---------------------------------------------------------------------
		
		static private var _instance:DeepLinkingManager;
		
		/**
		 * Enforced by Singleton Enforcer. 
		 * @param enforcer
		 * 
		 */		
		public function DeepLinkingManager(enforcer:SingletonEnforcer)
		{
			
		}
		
		/**
		 * Returns the Singleton Instance.
		 * @return 
		 * 
		 */		
		public static function getInstance():DeepLinkingManager
		{
			if(!DeepLinkingManager._instance)
				DeepLinkingManager._instance = new DeepLinkingManager(new SingletonEnforcer());
			return DeepLinkingManager._instance;
		}
		
		//---------------------------------------------------------------------
		//
		//  Private Properties
		//
		//---------------------------------------------------------------------
		private var _browserManager:IBrowserManager;
		private var _parsing:Boolean = false;
		private var _initialized:Boolean = false;
		private var _application:UIComponent;
		private var _navigationElements:Vector.<NavigationControl>;
		private var _delimiter:String = ";";
		private var _titleFunction:Function;
		private var _initialParseFunction:Function;
		//---------------------------------------------------------------------
		//
		//  Private Methods
		//
		//---------------------------------------------------------------------
		/**
		 * @private
		 * Sets the initial state of the application. 
		 */		
		private function _setInitialState():void
		{
			var url:String = _browserManager.url;
			if(_initialParseFunction!=null)
			{
				var parameters:Object = _initialParseFunction.call(null, url);
				for (var name:String in parameters)
					_navigationElements.push(new NavigationControl( name, null, null, parameters[name]));
			}
		}
		
		/**
		 * @private
		 * Updates the url based on the application state. 
		 */		
		private function _actuallyUpdateUrl():void
		{
			var i:int = -1;
			var n:int = _navigationElements.length;
			var fragment:Object = {};
			while(++i<n)
			{
				if(_navigationElements[i].instance && _navigationElements[i].instance[_navigationElements[i].property] != _navigationElements[i].defaultValue)
					fragment[_navigationElements[i].name] = _navigationElements[i].instance[_navigationElements[i].property].toString();
				else if(_navigationElements[i].heldValue && _navigationElements[i].instance==null)
					fragment[_navigationElements[i].name] = _navigationElements[i].heldValue;
			}
			_browserManager.setFragment( URLUtil.objectToString(fragment, _delimiter) );
		}
		
		/**
		 * @private
		 * Parses the url to set the application state. 
		 * @param event
		 */		
		private function _parseUrl(event:Event=null):void
		{
			// set parsing to true
			// to stop updating url 
			_parsing = true;
			var fragment:Object = URLUtil.stringToObject( _browserManager.fragment, _delimiter );
			for (var name:String in fragment)
			{
				var i:int = -1;
				var n:int = _navigationElements.length;
				while(++i<n)
				{
					if(name==_navigationElements[i].name)
					{
						_setValue(_navigationElements[i], fragment[name]);
						break;
					}
				}
			}
			//set title
			if(_titleFunction!=null)
				_browserManager.setTitle(_titleFunction.call(null, _navigationElements));
			// parsing done
			_parsing = false;
		}
		
		/**
		 * Sets the value on a uicomponent, called when instance is registered or when
		 * the url is being parsed. 
		 * @param element
		 * @param property
		 * 
		 */		
		private function _setValue(element:NavigationControl, property:Object):void
		{
			// if instance doesn't exist yet
			// quit
			if(!element.instance)
			{
				element.heldValue = property.toString();	
				return;
			}
			if(element.instance is ViewStack)
			{
				var index:int = int(property);
				if(-1<index && index<ViewStack(element.instance).length)
				{
					element.instance[element.property] = index;
					element.instance.validateNow();
				}
			} else {
				if(element.property=="currentState")
				{
					var states:Array = element.instance.states;
					var i:int = -1;
					var n:int = states.length;
					while(++i<n)
					{
						if(State(states[i]).name == property)
						{
							element.instance[element.property] = property; 
							break;
						}
					}
				} else {
					element.instance[element.property] = property; 
				}
			}
		}
		//---------------------------------------------------------------------
		//
		//  Public Methods
		//
		//---------------------------------------------------------------------
		/**
		 * Initial setup for the DeepLinkingManager. Nothing starts before
		 * this function is called.
		 * 
		 * <p>
		 * Requires the application to start up and any functions you may
		 * wish to alter the class, such as a function to determine the
		 * titleFunction.
		 * </p>
		 *  
		 * @param initialFragment
		 * @param initialTitle
		 * @param mainApplication
		 * @param titleFunction
		 * @param initialParseFunction
		 * @param delimiter
		 * 
		 */		
		public function init(initialFragment:String, initialTitle:String, mainApplication:UIComponent, titleFunction:Function=null, initialParseFunction:Function=null, delimiter:String=";"):Vector.<NavigationControl>
		{
			_initialized = true;
			_application = mainApplication;
			_navigationElements = new Vector.<NavigationControl>();
			_browserManager = BrowserManager.getInstance();
			_browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, _parseUrl);
			_browserManager.init(initialFragment,initialTitle);
			_titleFunction = titleFunction;
			_initialParseFunction = initialParseFunction;
			_setInitialState();
			return _navigationElements;
		}
		
		/**
		 * Registers a uicomponent to effect the deep linking url.
		 * 
		 * <p>
		 * Possibly will add in validation information.
		 * </p>
		 * 
		 * @param name
		 * @param instance
		 * @param property
		 * 
		 */		
		public function registerNavigationControl(name:String, instance:UIComponent, property:String, defaultValue:Object=null):int
		{
			var i:int = -1;
			var n:int = _navigationElements.length;
			var found:Boolean = false;
			// see if the element was in the initial
			// set of urls
			while(++i<n)
			{
				if(_navigationElements[i].name==name)
				{
					_navigationElements[i].instance = instance;
					_navigationElements[i].property = property;
					_navigationElements[i].defaultValue = defaultValue;
					_setValue(_navigationElements[i], _navigationElements[i].heldValue);
					found = true;
					break;
				}
			}
			// if found
			// when registering update view
			if(found)
			{
				_parseUrl();
				return _navigationElements.length;
			} else {
				// if not found
				// register element
				return _navigationElements.push(new NavigationControl(name, instance, property, null, defaultValue));
			}
		}
		
		/**
		 * Unregisters a uicomponent from effecting the deep linking url. 
		 * @param name
		 * @param instance
		 * 
		 */		
		public function unRegisterNavigationControl(name:String, instance:UIComponent):int
		{
			var i:int = -1;
			var n:int = _navigationElements.length;
			while(++i<n)
			{
				if(_navigationElements[i].instance==instance)
				{
					_navigationElements.splice(i,1);
					break;
				}
			}
			return _navigationElements.length;
		}
		
		/**
		 * Update the current URL - if not parsing the url. 
		 */		
		public function updateUrl():void
		{
			if(_parsing==false)
				_application.callLater(_actuallyUpdateUrl);
		}
		
		/**
		 * Removes the Deep Linking from the system.
		 * 
		 * <p>
		 * Effectively turns it off.
		 * </p> 
		 * 
		 */		
		public function removeDeepLinking():DeepLinkingManager
		{
			return DeepLinkingManager._instance = null;
		}
		
		//---------------------------------------------------------------------
		//
		//  Static Functions
		//
		//---------------------------------------------------------------------
		/**
		 * Takes a URL string and parses it as if it is
		 * a Php generated string.
		 * @param url
		 * @return 
		 * 
		 */		
		public static function phpStyleParseFunction(url:String):Object
		{
			var noHttp:String = removeHttpPortion(url);
			var queryStringStartIndex:int = noHttp.indexOf("?");
			var fragmentStartIndex:int = noHttp.indexOf("#");
			var returnObject:Object = {};
			if(queryStringStartIndex>-1)
			{
				var to:int = (fragmentStartIndex==-1)?noHttp.length:fragmentStartIndex-1;
				var queryString:String = noHttp.substring(queryStringStartIndex+1, to);
				returnObject = _loopThoughPairsToCreateObject(queryString.split(";"), returnObject);
			}
			if(fragmentStartIndex>-1)
			{
				var fragmentString:String = noHttp.substring(fragmentStartIndex+1);
				returnObject = _loopThoughPairsToCreateObject(fragmentString.split(";"), returnObject);
			}
			return returnObject;
		}
		
		/**
		 * Takes a URL string and parses it as if it is
		 * a Ruby on Rails generated string. 
		 * @param url
		 * @return 
		 * 
		 */		
		public static function rubyStyleParseFunction(url:String):Object
		{
			var noHttp:String = removeHttpPortion(url);
			var queryStringStartIndex:int = noHttp.indexOf("?");
			var fragmentStartIndex:int = noHttp.indexOf("#");
			var returnObject:Object = {};
			//
			var to:int = (queryStringStartIndex>-1)?queryStringStartIndex:(fragmentStartIndex>-1)?fragmentStartIndex:noHttp.length;
			var contextString:String = noHttp.substring(0,to);
			returnObject = _loopToCreateObject(contextString, returnObject);
			//query string
			if(queryStringStartIndex>-1)
			{
				to = (fragmentStartIndex==-1)?noHttp.length:fragmentStartIndex-1;
				var queryString:String = noHttp.substring(queryStringStartIndex+1, to);
				returnObject = _loopThoughPairsToCreateObject(queryString.split(";"), returnObject);
			}
			//fragment string
			if(fragmentStartIndex>-1)
			{
				var fragmentString:String = noHttp.substring(fragmentStartIndex+1);
				returnObject = _loopThoughPairsToCreateObject(fragmentString.split(";"), returnObject);
			}
			return returnObject;
		}
		
		/**
		 * Removes the url address and possible trailing
		 * slash from a sting. 
		 * @param url
		 * @return 
		 * 
		 */		
		public static function removeHttpPortion(url:String):String
		{
			var pattern:RegExp = /https?:\/\/(\w+\.)+\w+\/?/;
			var results:Array = pattern.exec(url);
			if(results)
				return url.replace(results[0], "");
			else
				return url;
		}
		
		/**
		 * Loops through the elements and splits up their pairs to 
		 * create an object of the ordered pairs. 
		 * @param elements
		 * @param item
		 * @param delimiter
		 * @return 
		 * 
		 */		
		private static function _loopThoughPairsToCreateObject(elements:Array, item:Object, delimiter:String="="):Object
		{
			var n:int = elements.length;
			var i:int = -1;
			while(++i<n)
			{
				var split:Array = (elements[i] as String).split(delimiter);
				item[split[0]] = split[1];
			}
			return item;
		}
		
		/**
		 * @private
		 * Loops through the string and creates an object with the elements
		 * placed in i,i+1 order respectively. 
		 * @param substring
		 * @param item
		 * @param delimiter
		 * @return 
		 * 
		 */		
		private static function _loopToCreateObject(substring:String, item:Object, delimiter:String="/"):Object
		{
			var elements:Array = substring.split("/");
			var n:int = elements.length;
			//
			if(n==1)
				return item;
			//
			var i:int=0;
			while(i<n)
			{
				item[elements[i]] = elements[i+1];
				i=i+2;
			}
			//
			return item;
		}
	}
}
import mx.containers.ViewStack;
import mx.core.UIComponent;
/**
 * Singleton Enforcer. 
 * @author jonbcampos
 * 
 */
class SingletonEnforcer{}
/**
 * Hold object for Navigation Control. 
 * @author jonbcampos
 * 
 */
class NavigationControl
{
	public function NavigationControl(name:String, instance:UIComponent, property:String, heldValue:String=null, defaultValue:Object=null)
	{
		_name = name;
		this.instance = instance;
		this.property = property;
		this.heldValue = heldValue;
		this.defaultValue = defaultValue;
	}
	
	private var _name:String;
	/**
	 * Default value to ignore when creating url.
	 */	
	public var defaultValue:Object;
	/**
	 * Property to track in url. 
	 */	
	public var property:String;
	/**
	 * Held value for when the component is registered. 
	 */	
	public var heldValue:String;
	/**
	 * UIComponent Instance.
	 */	
	public var instance:UIComponent;
	/**
	 * Name of the element, used for the name in the url.
	 */	
	public function get name():String
	{
		return _name;
	}
	
}