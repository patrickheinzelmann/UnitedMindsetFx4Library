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
package com.unitedmindset.validators
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	/**
	 * Boolean Validator, good for comboboxes.
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