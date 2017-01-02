// copied from
// http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/

// TODO (future): this is not quite working right (either version)

// TODO (future): try Andy's MetadataService
// https://github.com/financialforcedev/apex-mdapi
// https://github.com/financialforcedev/apex-mdapi/issues/93

public with sharing class TDB_DependentPicklists {

	public static Map<String, List<String>> getDependentOptionsOld(String pObjName, String pControllingFieldName, String pDependentFieldName)
	{
		Map<String, List<String>> objResults = new Map<String, List<String>>();

		//get the String to sobject global map
		Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
		if (!Schema.getGlobalDescribe().containsKey(pObjName))
			return objResults;

		//get the type being dealt with
		Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
		return getDependentOptionsImpl(pType, pControllingFieldName, pDependentFieldName);
	}

	public static Map<String, List<String>> getDependentOptionsImpl(Schema.SObjectType pType, String pControllingFieldName, String pDependentFieldName)
	{
		Map<String, List<String>> objResults = new Map<String, List<String>>();

		if (pType == null)
			return objResults;

		Bitset bitSetInstance = new Bitset();

		Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

		//verify field names
		if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
			return objResults;

		//get the control values
		List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
		//get the dependent values
		List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

		objFieldMap = null;

		List<Integer> lstControllingIndexes = new List<Integer>();
		//iterate through the values and get the ones valid for the controlling field name
		//set up the results
		for (Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++)
		{
			//get the pointer to the entry
			Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
			//get the label
			String pControllingLabel = ctrl_entry.getLabel();
			//create the entry with the label
			objResults.put(pControllingLabel, new List<String>());
			//keep track of the controlling indexes
			lstControllingIndexes.add(pControllingIndex);
		}

		//cater for null and empty
		objResults.put('', new List<String>());
		objResults.put(null, new List<String>());

		//load all dep entries
		List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
		List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();

		//add all entries
		for (Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++)
		{
			//get the pointer to the dependent index
			Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
			objEntries.add(dep_entry);
		}
		//serialize once
		objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(objEntries), List<TPicklistEntry>.class);

		List<Integer> validIndexes;
		for (TPicklistEntry objDepPLE : objDS_Entries)
		{
			//if valid for is empty, skip
			if (objDepPLE.validFor == null || objDepPLE.validFor == '')
				continue;

			//get the test for the controlling indexes
			validIndexes = bitSetInstance.testBits(objDepPLE.validFor, lstControllingIndexes);
			for (Integer validIndex : validIndexes)
			{
				//get the label
				String pControllingLabel = ctrl_ple[validIndex].getLabel();
				objResults.get(pControllingLabel).add(objDepPLE.label);
			}
		}
		objEntries = null;
		objDS_Entries = null;
		return objResults;
	}


///////////////////////////// BEGIN NU
	// Converts a base64 string into a list of integers representing the encoded bytes
	public static List<Integer> B64ToBytes(String sIn)
	{
		Map<Integer, Integer> base64 = new Map<Integer, Integer>
		{
			65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,
			78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,
			90=>25,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,
			107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,
			118=>47,119=>48,120=>49,121=>50,122=>51,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,
			55=>59,56=>60,57=>61,43=>62,47=>63
		};

		List<Integer> lstOut = new List<Integer>();
		if (sIn == null || sIn == '') return lstOut;

		sIn += '='.repeat(4 - Math.mod(sIn.length(), 4));

		for (Integer idx=0; idx < sIn.length(); idx += 4)
		{
			if (base64.get(sIn.charAt(idx+1)) != null) lstOut.add((base64.get(sIn.charAt(idx)) >>> 4));
			if (base64.get(sIn.charAt(idx+2)) != null) lstOut.add(((base64.get(sIn.charAt(idx+1)) & 15) >>> 2));
			if (base64.get(sIn.charAt(idx+3)) != null) lstOut.add(((base64.get(sIn.charAt(idx+2)) & 3) << 6) | base64.get(sIn.charAt(idx+3)));
		}

		//System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
		return lstOut;
	}//B64ToBytes

	public static List<Integer> BlobToBytes(Blob input)
	{
		return B64ToBytes(EncodingUtil.base64Encode(input));
	}//BlobToBytes

	// Converts a base64 string into a list of integers indicating at which position the bits are on
	public static List<Integer> cnvBits (String b64Str)
	{
		List<Integer> lstOut = new List<Integer>();
		if (b64Str == null || b64Str == '') return lstOut;

		List<Integer> lstBytes = B64ToBytes(b64Str);

		Integer i, b, v;
		for (i=0; i<lstBytes.size(); i++)
		{
			v = lstBytes[i];
			//System.debug ( 'i['+i+'] v['+v+']' );
			for ( b = 1; b <= 8; b++ )
			{
				//System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
				if ( ( v & 128 ) == 128 ) lstOut.add( (i*8) + b );
				v <<= 1;
			}
		}

		//System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
		return lstOut;
	}//cnvBits

	public static Map<String, List<String>> getDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName)
	{
		Map<String, List<String>> mapResults = new Map<String, List<String>>();

		//verify/get object schema
		Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
		if (pType == null) return mapResults;
		Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

		//verify field names
		if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;

		//get the control & dependent values
		List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
		List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

		//clear heap
		objFieldMap = null;

		//initialize results mapping
		for (Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++)
			mapResults.put(ctrl_ple[pControllingIndex].getLabel(), new List<String>());

		//cater for null and empty
		mapResults.put('', new List<String>());
		mapResults.put(null, new List<String>());

		//serialize dep entries
		List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
		objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

		List<Integer> validIndexes;
		for (TPicklistEntry objDepPLE : objDS_Entries)
		{
			validIndexes = cnvBits(objDepPLE.validFor);
			//System.Debug('cnvBits: [' + objDepPLE.label + '] = ' + validIndexes);

			for (Integer validIndex : validIndexes)
				mapResults.get( ctrl_ple[validIndex-1].getLabel() ).add( objDepPLE.label );
		}

		//clear heap
		objDS_Entries = null;

		return mapResults;
	}//getDependentOptions
///////////////////////////// END NU

	public class Bitset
	{
		public Map<String, Integer> alphaNumCharCodes { get; set; }
		public Map<String, Integer> base64CharCodes { get; set; }

		public Bitset()
		{
			loadCharCodes();
		}

		//Method loads the char codes
		private void loadCharCodes()
		{
			// upper case
			alphaNumCharCodes = new Map<String, Integer>
			{
				'!'=>33,'\"'=>34,'#'=>35,'$'=>36,'%'=>37,'&'=>38,'\\'=>39,'('=>40,')'=>41,
				'*'=>42,'+'=>43,','=>44,'-'=>45,'.'=>46,'/'=>47,'0'=>48,'1'=>49,'2'=>50,
				'3'=>51,'4'=>52,'5'=>53,'6'=>54,'7'=>55,'8'=>56,'9'=>57,':'=>58,';'=>59,
				'<'=>60,'='=>61,'>'=>62,'?'=>63,'@'=>64,
				'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
				'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
				'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90
			};
			base64CharCodes = new Map<String, Integer>();

			//lower case
			Set<String> pUpperCase = alphaNumCharCodes.keySet();

			for (String pKey : pUpperCase)
			{
				//the difference between upper case and lower case is 32
				alphaNumCharCodes.put(pKey.toLowerCase(), alphaNumCharCodes.get(pKey) + 32);
				//Base 64 alpha starts from 0 (The ascii charcodes started from 65)
				base64CharCodes.put(pKey, alphaNumCharCodes.get(pKey) - 65);
				base64CharCodes.put(pKey.toLowerCase(), alphaNumCharCodes.get(pKey) - (65) + 26);
			}

			//numerics
			for (Integer i=0; i<=9; i++)
			{
				alphaNumCharCodes.put(String.valueOf(i),i + 48);
				//base 64 numeric starts from 52
				base64CharCodes.put(String.valueOf(i), i + 52);
			}
		}

		/*
			Effect: Method takes a validFor String and tests it against a set of controlling indexes
			Postcondition: Returns a list of all controlling indexes for which the validFor String test True
		*/
		public List<Integer> testBits(String pValidFor, List<Integer> nList)
		{
			List<Integer> results = new List<Integer>();
			//the list of bytes (not derived from n)
			List<Integer> pBytes = new List<Integer>();
			//multiply by 6 since base 64 uses 6 bits (not derived form n)
			Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
			//will be used to hold the full decimal value (not derived from n)
			Integer pFullValue = 0;
			//must be more than 1 byte
			if (bytesBeingUsed <= 1)
				return results;
			//get the base64bytes
			for (Integer i=0; i<pValidFor.length(); i++)
			{
				//get currenct character value
				pBytes.add((base64CharCodes.get((pValidFor.substring(i, i+1)))));
			}

			//calculate the full decimal value
			for (Integer i = 0; i < pBytes.size(); i++)
			{
				Integer pShiftAmount = (pBytes.size() - (i+1)) * 6; //used to shift by a factor 6 bits to get the value
				pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
			}
			//now we don't want to always be declaring memory, so let's set the initial
			//variables
			Integer bit;
			Integer targetOctet;
			Integer shiftBits;
			Integer tBitVal;
			Integer n;
			Integer nListSize = nList.size();
			for (Integer i=0; i<nListSize; i++)
			{
				n = nList[i];
				//calculate the target bit for comparison
				bit = 7 - (Math.mod(n,8));
				//calculate the octet that has in the target bit
				targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed);
				//the number of bits to shift by until we find the bit to compare for true or false
				shiftBits = (targetOctet * 8) + bit;
				//& is to set the same set of bits for testing
				//shift to the bit which will dictate true or false
				//Math.Pow(2, shiftBits) == 2 << (shiftBits+1)
				tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
				if (tBitVal==1)
					results.add(n);
			}
			return results;
		}
	}

	/*
		* @Summary: Entity to represent a json version of a picklist entry
		* so that the validFor property becomes exposed
	*/
	public class TPicklistEntry
	{
		public String active {get;set;}
		public String defaultValue {get;set;}
		public String label {get;set;}
		public String value {get;set;}
		public String validFor {get;set;}

		public TPicklistEntry() { }
	}

}
