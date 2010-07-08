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
package com.unitedmindset.utils
{
	import flash.display.Sprite;
	
	import mx.controls.Alert;
	import mx.validators.Validator;
	
	/**
	 * Utilities that deal with forms. 
	 * @author jonbcampos
	 * 
	 */	
	public class FormUtil
	{
		/**
		 * Form Validation Utility.
		 * 
		 * <p>Uses an array of Flex Validators and validates each.<br />
		 * On Fail: Display an alert with the field's <code>NAME</code> attribute and the error<br />
		 * On Pass: Call the function sent in the params
		 * </p>
		 * 
		 * @param validationArray array of validator objects
		 * @param resultFunction function to be called if validators all pass
		 * @param alertTitle
		 * @param alertMessage
		 * @param flags
		 * @param parent
		 * @param closeHandler
		 * @param iconClass
		 * @param defaultButtonFlag
		 * @param args parameters to pass with function call
		 * 
		 */		
		public static function formValidation(validationArray:Array,resultFunction:Function, alertTitle:String=null, alertMessage:String=null, 
			flags:uint=4, parent:Sprite=null, closeHandler:Function=null, iconClass:Class=null, defaultButtonFlag:uint=4,
			...args):void
        {
        	//set up strings
        	var alertTitleString:String = (alertTitle!=null)?alertTitle:"Form Input Error";
        	var alertMessageString:String = (alertMessage!=null)?alertMessage:"Um... I think you missed a few fields:\n";
            //run all validators 	                        
            var results:Array = Validator.validateAll(validationArray);
             //if the results array is empty then everything passed. If it's not empty then at least one validator didn't pass
             if(results.length>0){
                 var message:String = alertMessageString;
                 //loop through all the results, and retrieve the id of the source for the corresponding validator
                 var i:int=-1;
                 var length:int = results.length;
                 while(++i < length)
                 	message+=results[i].target.source.name+"\n";
                 Alert.show(message,alertTitleString,flags,parent,closeHandler,iconClass, defaultButtonFlag);
             } else  {
             	resultFunction.call(args);
             }
         }
	}
}