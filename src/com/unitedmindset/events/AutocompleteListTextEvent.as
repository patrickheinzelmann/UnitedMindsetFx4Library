package com.unitedmindset.events
{
	import flash.events.Event;
	
	import flashx.textLayout.operations.FlowOperation;
	
	import spark.events.TextOperationEvent;
	
	/**
	 * Autocomplete Text Operation Events. 
	 * @author jonbcampos
	 * 
	 */	
	public class AutocompleteListTextEvent extends TextOperationEvent
	{
		/**
		 *  The <code>TextOperationEvent.CHANGING</code> constant 
		 *  defines the value of the <code>type</code> property of the event 
		 *  object for a <code>changing</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
		 *       event listener that handles the event. For example, if you use 
		 *       <code>myButton.addEventListener()</code> to register an event listener, 
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>operation</code></td><td>The FlowOperation object
		 *       describing the editing operation being performed
		 *       on the text by the user.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
		 *       it is not always the Object listening for the event. 
		 *       Use the <code>currentTarget</code> property to always access the 
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType changing
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public static const TEXT_CHANGING:String = "textChanging";
		
		/**
		 *  The <code>TextOperationEvent.CHANGE</code> constant 
		 *  defines the value of the <code>type</code> property of the event 
		 *  object for a <code>change</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
		 *       event listener that handles the event. For example, if you use 
		 *       <code>myButton.addEventListener()</code> to register an event listener, 
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>operation</code></td><td>The FlowOperation object
		 *       describing the editing operation being performed
		 *       on the text by the user.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
		 *       it is not always the Object listening for the event. 
		 *       Use the <code>currentTarget</code> property to always access the 
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType change
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public static const TEXT_CHANGE:String = "textChange";
		
		private var _text:String;
		public function get text():String
		{
			return _text;
		}
		
		public function AutocompleteListTextEvent(type:String, text:String, bubbles:Boolean=false, cancelable:Boolean=true, operation:FlowOperation=null)
		{
			super(type, bubbles, cancelable, operation);
			_text = text;
		}
		
		override public function clone():Event
		{
			return new AutocompleteListTextEvent(type, text, bubbles, cancelable, operation);
		}
	}
}