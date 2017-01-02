public with sharing class TDB_ValueGenerator {

	// NOTE: this class is complete
	// you don't need to customize it unless you want to add features

	public static void assignValues(Sobject row, List<Schema.SObjectField> fieldList, Map<Schema.SObjectField, Object> constantValues)
	{
		assignValues(row, fieldList, constantValues, new Set<Schema.SObjectField>());
	}

	public static void assignValues(Sobject row, List<Schema.SObjectField> fieldList, Map<Schema.SObjectField, Object> constantValues, Set<Schema.SObjectField> requiredValues)
	{
		if (Userinfo.isMultiCurrencyOrganization()) row.put('CurrencyIsoCode', TDB_QueriedMetadata.randomCurrency);
		assignRandomValues(row, fieldList, constantValues, requiredValues);
		assignStaticValues(row, constantValues);
	}

	// NOTE: the OO way would be to break this down into impl of an interface
	// but pragmatic me didn't think the benefits outweight the simplicity of what is below
	// I reserve the right to change my mind
	private static void assignRandomValues(Sobject row, List<Schema.SObjectField> fieldList, Map<Schema.SObjectField, Object> constantValues, Set<Schema.SObjectField> requiredValues)
	{
		for (Schema.SObjectField f : fieldList)
		{
			Schema.DescribeFieldResult describe = f.getDescribe();
			Schema.DisplayType type = describe.getType();
			String fieldName = describe.getName();

			// when field static value is defined, skip generating a value
			if (constantValues.containsKey(f))
				continue;

			// non-required fields have a chance of being blank
			if (describe.isNillable() && !requiredValues.contains(f))
				if (TDB_Utils.noDataThisField())
					continue;

			if (type == DisplayType.String || type == DisplayType.TextArea || type == DisplayType.EncryptedString)
			{
				String val = getRandomString(describe.getLength() >= 8 ? 8 : describe.getLength());
				row.put(fieldName, val);
			}

			else if (type == DisplayType.Phone)
			{
				String val = getRandomLetters(12);
				row.put(fieldName, val);
			}

			else if (type == DisplayType.Email)
			{
				String val = getRandomLetters(8) + '@' + getRandomLetters(8) + '.com';
				row.put(fieldName, val);
			}

			else if (type == DisplayType.URL)
			{
				String val = 'http://www.' + getRandomLetters(8) + '.com';
				row.put(fieldName, val);
			}

			else if (type == DisplayType.Picklist || type == DisplayType.MultiPicklist)
			{
				List<Schema.PicklistEntry> choices = describe.getPicklistValues();
				String defaultValue = '';
				List<String> activeValues = new List<String>();
				for (Schema.PicklistEntry ent : choices)
				{
					if (ent.isDefaultValue())
						defaultValue = ent.getValue();
					if (ent.isActive())
						activeValues.add(ent.getValue());
				}

				// QUESTION: any reason to favor defaultValue ?
				if (activeValues.size() > 0)
				{
					if (type == DisplayType.Picklist)
					{
						Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), activeValues.size());
						row.put(fieldName, activeValues.get(randomIndex));
					}
					else // MultiPicklist
					{
						Integer randomSelectionCount = Math.mod(Math.abs(Crypto.getRandomInteger()), activeValues.size()) + 1;

						// NOTE: remove() not so efficient as swap but good enough for this use case
						List<String> selectedValues = new List<String>();
						for (Integer i=0; i<randomSelectionCount; i++)
						{
							Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), activeValues.size());
							selectedValues.add(activeValues.get(randomIndex));
							activeValues.remove(randomIndex);
						}
						row.put(fieldName, String.join(selectedValues, '; ' ));
					}
				}
			}

			else if (type == DisplayType.Integer)
			{
				// TODO (future): check size first
				Integer val = getRandomInteger(4);
				row.put(fieldName, val);
			}

			else if (type == DisplayType.Percent)
			{
				Integer val = getRandomInteger(2);
				row.put(fieldName, val / 100);
			}

			else if (type == DisplayType.Double || type == DisplayType.Currency)
			{
				// TODO (future): check size first
				Double val = getRandomInteger(3) / 100;
				row.put(fieldName, val);
			}

			else if (type == DisplayType.Boolean)
			{
				Integer val = getRandomInteger(1);
				row.put(fieldName, (val > 5));
			}

			else if (type == DisplayType.Date)
			{
				Integer randomDays = Math.mod(Math.abs(Crypto.getRandomInteger()), 720) - 365;
				row.put(fieldName, Date.today() + randomDays);
			}

			else if (type == DisplayType.DateTime)
			{
				Integer randomDays = Math.mod(Math.abs(Crypto.getRandomInteger()), 720) - 365;
				Date dateVal = Date.today() + randomDays;
				Time timeVal = Time.newInstance(
					Math.mod(Math.abs(Crypto.getRandomInteger()), 24),
					Math.mod(Math.abs(Crypto.getRandomInteger()), 60),
					Math.mod(Math.abs(Crypto.getRandomInteger()), 60),
					Math.mod(Math.abs(Crypto.getRandomInteger()), 1000)
				);
				row.put(fieldName, DateTime.newInstance(dateVal, timeVal));
			}

			else
			{
				// apparently missing a data type
				throw TDB_Utils.getExceptionInstance('Not able to create random data for type ' + type);
			}
		}
	}

	private static void assignStaticValues(Sobject row, Map<Schema.SObjectField, Object> constantValues)
	{
		for (Schema.SObjectField f : constantValues.keySet())
		{
			Schema.DescribeFieldResult describe = f.getDescribe();
			row.put(describe.getName(), constantValues.get(f));
		}
	}

	private static String getRandomLetters(Integer len)
	{
		return getRandomText(len, true);
	}

	private static String getRandomString(Integer len)
	{
		return getRandomText(len, false);
	}

	private static String getRandomText(Integer len, Boolean lettersOnly)
	{
		String startEndCharChoices = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String middleCharChoices = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz1234567890 _-+=!@#$%^*&()[]';

		String randStr = '';
		while (randStr.length() < len)
		{
			String charChoices = (lettersOnly || randStr.length() == 0 || randStr.length() == len - 1 ? startEndCharChoices : middleCharChoices);
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charChoices.length());
			randStr += charChoices.substring(idx, idx+1);
		}

		return randStr;
	}

	private static Integer getRandomInteger(Integer len)
	{
		String startCharChoices = '123456789';
		String notStartCharChoices = '1234567890';

		String randStr = '';
		while (randStr.length() < len)
		{
			String charChoices = (randStr.length() == 0 ? startCharChoices : notStartCharChoices);
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charChoices.length());
			randStr += charChoices.substring(idx, idx+1);
		}
		return Integer.valueOf(randStr);
	}

}
