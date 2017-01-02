public with sharing class TDB_Utils {

	// NOTE: this class is complete
	// you don't need to customize it unless you want to add features

	public static Map<String, String> getCustomMetadataMap(String developerName)
	{
		Map<String, String> params = new Map<String, String>();

		List<TDB_Parameters__mdt> rows =
			[SELECT Id, MasterLabel, DeveloperName, Value__c, Optional_Value__c, Description__c
			FROM TDB_Parameters__mdt
			WHERE DeveloperName = :developerName];

		if (rows.size() > 0)
		{
			TDB_Parameters__mdt row = rows.get(0);

			Matcher matched = Pattern.compile('(.+?):\\s*(.+?)(?:\\r*\\n|$)').matcher(row.Value__c + '\n' + row.Optional_Value__c);
			while (matched.find())
				params.put(matched.group(1).trim(), matched.group(2).trim());
		}

		return params;
	}

	public static Boolean noDataThisField()
	{
		if (TDB_Constants.CHANCE_FIELD_BLANK < 1) return false;

		Integer rollOfDice = Math.mod(Math.abs(Crypto.getRandomInteger()), 100) + 1;
		return (rollOfDice <= TDB_Constants.CHANCE_FIELD_BLANK);
	}

	public static Map<String, sObject> mapByString(List<sObject> rows, String keyName)
	{
		Map<String, sObject> res = new Map<String, sObject>();

		for (sObject o : rows)
			res.put((String)o.get(keyName), o);

		return res;
	}

	public static Integer listIndexOf(List<Object> l, Object val)
	{
		for (Integer i=0; i<l.size(); i++)
			if (l.get(i) == val) return i;
		return -1;
	}


	public class DataBundleException extends Exception { }
	public static Exception getExceptionInstance(String e)
	{
		return new DataBundleException(e);
	}

}
