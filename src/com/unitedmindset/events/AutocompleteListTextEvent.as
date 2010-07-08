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