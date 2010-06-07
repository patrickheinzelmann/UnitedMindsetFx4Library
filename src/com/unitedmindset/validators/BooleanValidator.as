package com.unitedmindset.validators
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	/**
	 * Boolean Validator, good for comboboxes
	 * */
	public class BooleanValidator extends Validator
	{
		public function BooleanValidator()
		{
			super();
		}
		
		/**
		 * @private
		 * Loads resources for this class
		 * */
		private static function validateBoolean(validator:BooleanValidator, value:Boolean,baseField:String=null):Array
		{
			var results:Array = [];
			if(!value){
				results.push(new ValidationResult(true,baseField,"required","This field is required."));
				return results;
			}
			return results;
		}
		
		override protected function doValidation(value:Object):Array
		{
			var results:Array = super.doValidation(value);
			//return if there are errors
			//or if the required property is set to false and length is 0
			var val:String = value? String(value):"";
			if(results.length > 0 || ((val.length==0) && !required))
				return results;
			else
				return BooleanValidator.validateBoolean(this,(value as Boolean), null);
		}
		
	}
}