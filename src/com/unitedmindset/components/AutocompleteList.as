package com.unitedmindset.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.errors.ItemPendingError;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.DropDownList;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.DropDownController;
	import spark.components.supportClasses.DropDownListBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	import spark.utils.LabelUtil;
	
	/**
	 * Fired when the compareLabel is changed. 
	 */	
	[Event(name="compareLabelChange",type="flash.events.Event")]
	/**
	 * Fired when the compareFunction is changed. 
	 */	
	[Event(name="compareFunctionChange",type="flash.events.Event")]
	/**
	 * Fired when the list opens. 
	 */	
	[Event(name="open", type="spark.events.DropDownEvent")]
	/**
	 * Fired when the list closes. 
	 */	
	[Event(name="close", type="spark.events.DropDownEvent")]
	
	[SkinState("open")]
	
	/**
	 * Autocomplete component based on the List. 
	 * @author jonbcampos
	 * 
	 */	
	public class AutocompleteList extends List
	{
		public static const COMPARELABEL_CHANGE_EVENT:String = "compareLabelChange";
		public static const COMPAREFUNCTION_CHANGE_EVENT:String = "compareFunctionChange";
		
		public function AutocompleteList()
		{
			super();
			
			super.allowMultipleSelection = false;
			
			dropDownController = new DropDownController();
			addEventListener(IndexChangeEvent.CHANGE, _onList_ChangeHandler);
			addEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
			addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		}

		//---------------------------------------------------------------------
		//
		//   Skin Parts
		//
		//---------------------------------------------------------------------
		
		[SkinPart(required="true")]
		/**
		 * A skin part that defines a textinput that
		 * you use to type in for the autocomplete search.
		 */		
		public var textInput:TextInput;
		
		[SkinPart(required="false")]
		
		/**
		 *  A skin part that defines the drop-down list area. When the DropDownListBase is open,
		 *  clicking anywhere outside of the dropDown skin part closes the   
		 *  drop-down list. 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var dropDown:DisplayObject;
		
		//---------------------------------------------------------------------
		//
		//   Private Properties
		//
		//---------------------------------------------------------------------
		/**
		 * @private
		 * Flag for invalidateProperties.
		 */	
		private var _compareChanged:Boolean = false;
		//---------------------------------------------------------------------
		//
		//   Public Properties
		//
		//---------------------------------------------------------------------
		
		//---------------------------------
		// caseSensitive
		//---------------------------------
		/**
		 * Flag to filter the text with or without
		 * case sensitivity. 
		 */		
		public var caseSensitive:Boolean = false;
		
		//---------------------------------
		// compareLabel
		//---------------------------------
		/**
		 * @private 
		 */	
		private var _compareLabel:String = "";
		
		[Bindable(event="compareLabelChange")]
		/**
		 * If the dataProvider is based on the
		 * objects, the compareLabel is the property
		 * on the object that will be used for the
		 * compare function. 
		 */		
		public function get compareLabel():String
		{
			if(_compareLabel==""||_compareLabel==null)
				return super.labelField;
			return _compareLabel;
		}
		
		/**
		 * @private 
		 */		
		public function set compareLabel(value:String):void
		{
			if (_compareLabel != value) {
				_compareLabel = value;
				dispatchEvent(new Event(COMPARELABEL_CHANGE_EVENT));
				if(isDropDownOpen)
					invalidateList();
			}
		}
		//---------------------------------
		// compareFunction
		//---------------------------------
		/**
		 * @private 
		 */	
		private var _compareFunction:Function = null;
		
		[Bindable(event="compareFunctionChange")]
		/**
		 * Custom function to call for filtering
		 * the dataprovider.
		 */		
		public function get compareFunction():Function
		{
			return _compareFunction;
		}
		
		/**
		 * @private 
		 */	
		public function set compareFunction(value:Function):void
		{
			if (_compareFunction != value) {
				_compareFunction = value;
				dispatchEvent(new Event(COMPAREFUNCTION_CHANGE_EVENT));
				if(isDropDownOpen)
					invalidateList();
			}
		}
		
		//---------------------------------
		// dataProvider
		//---------------------------------
		/**
		 * @private 
		 */	
		private var _oldDataProvider:IList;
		
		/**
		 *  Makes sure to wrap the dataprovider in an ICollection
		 *  implementation so that we have filterFunction ability.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */	
		override public function get dataProvider():IList
		{
			return super.dataProvider;
		}
		
		/**
		 * @private 
		 */	
		override public function set dataProvider(value:IList):void
		{
			if(_oldDataProvider==value)
				return;
			
			_oldDataProvider = value;
			
			//if IList is ICollection view, done
			if(value is ICollectionView)
			{
				super.dataProvider = value;
			}
			
			//make IList into ICollectionView
			if(value is IList)
			{
				super.dataProvider = new ArrayCollection(value.toArray());
			}
		}
		
		//----------------------------------
		//  dropDownController
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _dropDownController:DropDownController; 
		
		/**
		 *  Instance of the DropDownController class that handles all of the mouse, keyboard 
		 *  and focus user interactions. 
		 * 
		 *  Flex calls the <code>initializeDropDownController()</code> method after 
		 *  the DropDownController instance is created in the constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function get dropDownController():DropDownController
		{
			return _dropDownController;
		}
		
		/**
		 *  @private
		 */
		protected function set dropDownController(value:DropDownController):void
		{
			if (_dropDownController == value)
				return;
			
			_dropDownController = value;
			
			_dropDownController.addEventListener(DropDownEvent.OPEN, _dropDownController_openHandler);
			_dropDownController.addEventListener(DropDownEvent.CLOSE, _dropDownController_closeHandler);
			
		}
		
		//----------------------------------
		//  isDropDownOpen
		//----------------------------------
		
		/**
		 *  @copy spark.components.supportClasses.DropDownController#isOpen
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get isDropDownOpen():Boolean
		{
			if (dropDownController)
				return dropDownController.isOpen;
			else
				return false;
		}
		
		//---------------------------------------------------------------------
		//
		//   Override Methods
		//
		//---------------------------------------------------------------------
		/**
		 * @private
		 */		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == textInput)
			{
				textInput.addEventListener(TextOperationEvent.CHANGE, _onTextInput_TextChange);
				textInput.addEventListener(FocusEvent.FOCUS_OUT, _onTextInput_FocusOutHandler);
			}
			else if (instance == dropDown && dropDownController)
			{
				dropDownController.dropDown = dropDown;
			}
		}
		
		/**
		 * @private 
		 */		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (dropDownController)
			{
				if (instance == dropDown)
					dropDownController.dropDown = null;
			}
			
			super.partRemoved(partName, instance);
			
			if(instance == textInput)
			{
				textInput.removeEventListener(TextOperationEvent.CHANGE, _onTextInput_TextChange);
				textInput.removeEventListener(FocusEvent.FOCUS_OUT, _onTextInput_FocusOutHandler);
			}
		}
		
		/**
		 * @private 
		 */		
		override protected function commitProperties():void
		{
			super.commitProperties();
			//compareChanged
			if(_compareChanged)
			{
				_compareChanged = false;
				evaluateList();
			}
		}
		
		/**
		 * @private 
		 */		
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
		}
		//---------------------------------------------------------------------
		//
		//   Public Methods
		//
		//---------------------------------------------------------------------
		/**
		 * Invalidates list and recalls for new compare.
		 */		
		public function invalidateList():void
		{
			_compareChanged = true;
			invalidateProperties();
		}
		//---------------------------------------------------------------------
		//
		//   Handler Methods
		//
		//---------------------------------------------------------------------
		/**
		 * @private
		 */
		private function _onTextInput_TextChange(event:TextOperationEvent):void
		{
			invalidateList();
			evaluateList();
		}
		
		/**
		 * @private
		 */
		private function _dropDownController_openHandler(event:DropDownEvent):void
		{
			addEventListener(FlexEvent.UPDATE_COMPLETE, _open_updateCompleteHandler);
			invalidateSkinState();  
		}
		
		/**
		 * @private
		 */
		private function _open_updateCompleteHandler(event:FlexEvent):void
		{   
			removeEventListener(FlexEvent.UPDATE_COMPLETE, _open_updateCompleteHandler);
			
			dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
		}
		
		/**
		 * @private
		 */
		private function _dropDownController_closeHandler(event:DropDownEvent):void
		{
			addEventListener(FlexEvent.UPDATE_COMPLETE, _close_updateCompleteHandler);
			invalidateSkinState();
		}
		
		/**
		 * @private
		 */
		private function _close_updateCompleteHandler(event:FlexEvent):void
		{   
			removeEventListener(FlexEvent.UPDATE_COMPLETE, _close_updateCompleteHandler);
			
			dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
		}
		
		/**
		 * @private
		 */
		private function _onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.DOWN)
			{
				if(isDropDownOpen && selectedIndex<dataProvider.length)
					selectedIndex++;
				else
					dropDownController.openDropDown();
			}
			else if (event.ctrlKey && event.keyCode == Keyboard.UP)
			{
				dropDownController.closeDropDown(true);
			}    
			else if (event.keyCode == Keyboard.UP)
			{
				if(isDropDownOpen && selectedIndex>0)
					selectedIndex--;
			}    
			else if (event.keyCode == Keyboard.ENTER)
			{
				// Close the dropDown and eat the event if appropriate.
				if (isDropDownOpen)
				{
					dropDownController.closeDropDown(true);
					textInput.text = LabelUtil.itemToLabel(selectedItem, labelField, labelFunction);
				}
			}
			else if (event.keyCode == Keyboard.ESCAPE)
			{
				// Close the dropDown and eat the event if appropriate.
				if (isDropDownOpen)
					dropDownController.closeDropDown(false);
			}
			event.preventDefault();
		}
		
		//---------------------------------------------------------------------
		//
		//   Protected Methods
		//
		//---------------------------------------------------------------------
		/**
		 * If the textinput text length is greater than 0, 
		 * open the list and run compare. If 0, close list and
		 * clear filter.
		 */		
		protected function evaluateList():void
		{
			if(!dataProvider)
				return;
			if(textInput.text.length>0)
			{
				dropDownController.openDropDown();
				runCompare();
			} else {
				dropDownController.closeDropDown(false);
				clearCompare();
			}
		}
		
		/**
		 * Runs the compare function.
		 */		
		protected function runCompare():void
		{
			if(compareFunction!=null)
				(dataProvider as ICollectionView).filterFunction = compareFunction;
			else
				(dataProvider as ICollectionView).filterFunction = _labelCompareFunction;
			(dataProvider as ICollectionView).refresh();
		}
		
		/**
		 * Clears the compare function.
		 */		
		protected function clearCompare():void
		{
			(dataProvider as ICollectionView).filterFunction = null;
			(dataProvider as ICollectionView).refresh();
		}
		
		//---------------------------------------------------------------------
		//
		//   Private Methods
		//
		//---------------------------------------------------------------------
		/**
		 * @private 
		 */	
		private function _labelCompareFunction(item:Object):Boolean
		{
			var labelDisplay:String = LabelUtil.itemToLabel(item, compareLabel, null);
			if(caseSensitive){
				if(labelDisplay.indexOf(textInput.text)>-1)
					return true;
			} else {
				if(labelDisplay.toLowerCase().indexOf(textInput.text.toLowerCase())>-1)
					return true;
			}
			return false;
		}
		
		/**
		 * @private 
		 */	
		private function _onFocusIn(event:FocusEvent):void
		{
			if(textInput)
				focusManager.setFocus(textInput);
		}
		
		/**
		 * @private 
		 */	
		private function _onFocusOut(event:FocusEvent):void
		{
			dropDownController.processFocusOut(event);
		}
		
		/**
		 * @private 
		 */	
		private function _onTextInput_FocusOutHandler(event:FocusEvent):void
		{
			dropDownController.processFocusOut(event);
		}
		
		/**
		 * @private 
		 */	
		private function _onList_ChangeHandler(event:IndexChangeEvent):void
		{
			textInput.text = LabelUtil.itemToLabel((event.target as List).selectedItem, labelField, labelFunction);
		}
		
	}
}