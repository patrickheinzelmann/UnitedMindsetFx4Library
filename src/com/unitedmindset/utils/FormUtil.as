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