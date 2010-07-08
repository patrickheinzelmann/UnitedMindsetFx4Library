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
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	/**
	 * Utility class to Validate Objects Against Classes 
	 * @author Administrator
	 * 
	 */	
	public class ClassValidationUtil
	{
		/**
		 * Validates that an object is of a specific class type. If the <i>objectToValidate</i> is an Array or ArrayCollection, the
		 * function will use the <i>secondaryClass</i> (if it exists) to check the objects in the array. This function only goes one
		 * level deep, not appropriate to check tree structures.
		 * 
		 * <pre>
		 * Test Found In MMALibraryTest :: ClassValidationUtilTest.as
		 * </pre>
		 *  
		 * @param objectToValidate
		 * @param primaryClass a class to check the object against
		 * @param secondaryClass a class to check if the primary class is an <code>array</code> or <code>arraycollection</code>
		 * @return <code>true</code> if the classes are equal type, <code>false</code> if they are not
		 * 
		 */		
		public static function validateClassStructure(objectToValidate:Object,primaryClass:Class,secondaryClass:Class=null):Boolean
		{
			// get names
			var primaryClassName:String = ObjectUtil.getClassInfo(primaryClass).name;
			var secondaryClassName:String = ObjectUtil.getClassInfo(secondaryClass).name;
			var objectToValidateName:String;
			if(objectToValidate is String)
				objectToValidateName = "String";
			else
				objectToValidateName = ObjectUtil.getClassInfo(objectToValidate).name;
			//first check that primary class and the object are the same
			if(objectToValidateName != primaryClassName)
				return false;
			//next we check the list of objects if the object to validate is an array or arraycollection
			if ((objectToValidate is Array || objectToValidate is ArrayCollection) && secondaryClass != null){
				//get array of objects
				var array:Array;
				if(objectToValidate is ArrayCollection)
					array = ArrayCollection(objectToValidate).source;
				else
					array = objectToValidate as Array;
				//get length
				var length:uint = array.length;
				var i:int=-1;
				//iterate through array and test
				while(++i < length){
					if(ObjectUtil.getClassInfo(array[i]).name != secondaryClassName)
						return false;
				}
			}
			//if we get through everything, return true
			return true;
		}
		
		/**
		 * Validates that an object that is an <code>Array</code> or an <code>ArrayCollection</code> is of a specific class type. 
		 * This function only goes one level deep, not appropriate to check tree structures.
		 * 
		 * @param objectToValidate
		 * @param primaryClass a class to check the object against
		 * @return <code>true</code> if the classes are equal type, <code>false</code> if they are not
		 * 
		 */		
		public static function validateClassArrayStructure(objectToValidate:Object,primaryClass:Class):Boolean
		{
			// get names
			var primaryClassName:String = ObjectUtil.getClassInfo(primaryClass).name;
			var objectToValidateName:String;
			if(objectToValidate is String)
				objectToValidateName = "String";
			else
				objectToValidateName = ObjectUtil.getClassInfo(objectToValidate).name;
			//first check that primary class is an objectToValidate and the object are the same
			if(objectToValidate is Array || objectToValidate is ArrayCollection){
				//get array of objects
				var array:Array;
				if(objectToValidate is ArrayCollection)
					array = ArrayCollection(objectToValidate).source;
				else
					array = objectToValidate as Array;
				//get length
				var length:uint = array.length;
				//iterate through array and test
				for(var i:int=0;i<length;i++){
					if(ObjectUtil.getClassInfo(array[i]).name != primaryClassName)
						return false;
				}
			} else {
				return false;
			}
			return true;
		}
		
		/**
		 * Validates that a tree objects nodes are all of a specific class type. Recursively checks all levels.
		 * 
		 * @param objectToValidate
		 * @param checkClass a class to check the object against, make sure they are of the same type.
		 * @param childrenProperty the property on the object that contains children.
		 * @param includeRoot whether to check the root or not against the <i>checkClass</i>.
		 * @return <code>true</code> if the classes are equal type, <code>false</code> if they are not
		 * 
		 */		
		public static function validateTreeStructure(objectToValidate:Object,checkClass:Class,includeRoot:Boolean=true,childrenProperty:String="children"):Boolean
		{
			//1. check that the object is a collection
			if(!objectToValidate is Array && !objectToValidate is ArrayCollection)
				return false;
			//2. check root
			var className:String = ObjectUtil.getClassInfo(checkClass).name;
			if(includeRoot){
				if(ObjectUtil.getClassInfo(objectToValidate).name != className)
					return false;
			}
			//3. check children
			// get array
			var array:Array;
			if(objectToValidate is ArrayCollection){
				array = ArrayCollection(objectToValidate).source;
			} else if(objectToValidate is Array){
				array = objectToValidate as Array;
			} else if(objectToValidate.hasOwnProperty(childrenProperty) && objectToValidate[childrenProperty] && objectToValidate[childrenProperty]!=null){
				if(objectToValidate[childrenProperty] is ArrayCollection)
					array = ArrayCollection(objectToValidate[childrenProperty]).source;
				else
					array = objectToValidate[childrenProperty];
			} else if(!objectToValidate.hasOwnProperty(childrenProperty)){
				return false;
			} else {
				return true;
			}
			// get array length
			var length:uint = array.length;
			var i:int=-1;
			// check each object
			var check:Boolean = true;
			while(++i < length){
				var o:Object = array[i];
				if(ObjectUtil.getClassInfo(o).name != className)
					check = false;
				if(check && o.hasOwnProperty(childrenProperty) && o[childrenProperty] && o[childrenProperty]!=null)
					check = validateTreeStructure(o[childrenProperty],checkClass,false,childrenProperty);
				else if(!o.hasOwnProperty(childrenProperty))
					check = false;
			}
			return check;
		}
		
	}
}