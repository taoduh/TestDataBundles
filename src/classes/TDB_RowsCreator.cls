public with sharing class TDB_RowsCreator {

	// CUSTOMIZATION NOTE: for each object that is not already implmented:
	// (1) implement DataCreator a la the DataCreatorTemplate sample below
	// (2) add an else if clause in the dataCreatorFactory() method to reference your new DataCreator

	// NOTE: if you have custom settings data that is needed before tests can be run
	// you can use methods like this to load the data from static resources
	public static void loadCustomSettings()
	{
		// if DML limits are a problem do something else such as hard-code and insert en masse
		//Test.loadData(my_custom_setting_obj__c.sObjectType, 'my_static_resource_file');
	}

	// create test data for one table
	// requestedFieldValues contains extra column data beyond the defaults in TDB_RowCreator
	public static List<Sobject> getRows(Schema.SObjectType table, Integer rowCount, Map<Schema.SObjectType, List<Id>> allForeignKeys, Map<String, Object> requestedFieldValues)
	{
		System.debug('TDB: To create rows in ' + table + ' some FKs are needed: ' + allForeignKeys);

		if (requestedFieldValues == null) requestedFieldValues = new Map<String, Object>();

		DataCreator dataCreator = dataCreatorFactory(table, rowCount, allForeignKeys, requestedFieldValues);
		return dataCreator.getRows(allForeignKeys, rowCount, requestedFieldValues);
	}

	// NOTE: no method reflection in Apex so let's go with a factory
	private static DataCreator dataCreatorFactory(Schema.SObjectType table, Integer rowCount, Map<Schema.SObjectType, List<Id>> allForeignKeys, Map<String, Object> requestedFieldValues)
	{
		DataCreator dataCreator;
		if (table == Account.sObjectType)
			dataCreator = new AccountDataCreator();
		else if (table == Contact.sObjectType)
			dataCreator = new ContactDataCreator();
		else if (table == Opportunity.sObjectType)
			dataCreator = new OpportunityDataCreator();
		else if (table == OpportunityContactRole.sObjectType)
			dataCreator = new OpportunityContactRoleDataCreator();
		else if (table == Product2.sObjectType)
			dataCreator = new Product2DataCreator();
		else if (table == Pricebook2.sObjectType)
			dataCreator = new Pricebook2DataCreator();
		else if (table == PricebookEntry.sObjectType)
			dataCreator = new PricebookEntryDataCreator();
		else if (table == OpportunityLineItem.sObjectType)
			dataCreator = new OpportunityLineItemDataCreator();
		else if (table == Lead.sObjectType)
			dataCreator = new LeadDataCreator();
		else if (table == Case.sObjectType)
			dataCreator = new CaseDataCreator();
		else if (table == Contract.sObjectType)
			dataCreator = new ContractDataCreator();

		//	else if (table == MyObject.sObjectType)
		//		dataCreator = new MyObjectDataCreator();

		else
		{
			// apparently missing an object case
			throw TDB_Utils.getExceptionInstance('No automation exists to create ' + table + ' rows.');
		}

		return dataCreator;
	}


	private interface DataCreator
	{
		List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues);
	}

	private virtual class VirtualDataCreator
	{
		// given all the foreign key values, extract the list by type and then return the proper key value by index
		// if the list has length = 1, always return that element
		// otherwise cycle through the list as many times as needed
		// prior validation ensures there isn't a strange mismatch in list counts
		private Id getForeignKeyValue(Map<Schema.SObjectType, List<Id>> allForeignKeys, Schema.SObjectType foreignKeyType, Integer index)
		{
			List<Id> foreignKeys = allForeignKeys.get(foreignKeyType);

			Integer loopedIndex = (foreignKeys.size() == 1 ? 0 : (index < foreignKeys.size() ? index : Math.mod(index, foreignKeys.size())));
			return foreignKeys.get(loopedIndex);
		}

		// add more column values beyond the defaults in TDB_RowCreator for a specific row
		private void addRequestedValues(SObject o, Integer index, Map<String, Object> requestedFieldValues)
		{
			for (String name : requestedFieldValues.keySet())
			{
				// if one value/row it will be passed in pipe-delimited
				// allowing literal pipes in the value will be a future enhancement, should just be some fancy regex
				List<String> allValues = ((String)requestedFieldValues.get(name)).split('\\|');
				Object value = allValues.get(0);
				if (allValues.size() > 1)
					value = allValues.get(Math.mod(index, allValues.size()));
				o.put(name, value);
			}
		}
	}

	private class AccountDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Account row = TDB_RowCreator.initAccount();
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}

			insert dataRows;
			return dataRows;
		}
	}

	private class ContactDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				// NOTE: would love for this to be dynamic sent to the TDB_RowCreator method
				// but that would require a python-esque dynamic way of passing in args which Apex can't do
				Id accountId = getForeignKeyValue(allForeignKeys, Account.SObjectType, i);

				Contact row = TDB_RowCreator.initContact(accountId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}

			insert dataRows;
			return dataRows;
		}
	}

	private class OpportunityDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Id accountId = getForeignKeyValue(allForeignKeys, Account.SObjectType, i);

				Opportunity row = TDB_RowCreator.initOpportunity(accountId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class OpportunityContactRoleDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Id contactId = getForeignKeyValue(allForeignKeys, Contact.SObjectType, i);
				Id opportunityId = getForeignKeyValue(allForeignKeys, Opportunity.SObjectType, i);

				OpportunityContactRole row = TDB_RowCreator.initContactRole(contactId, opportunityId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class Product2DataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Product2 row = TDB_RowCreator.initProduct();
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class Pricebook2DataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Pricebook2 row = TDB_RowCreator.initPricebook();
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class PricebookEntryDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			String currencyCode = TDB_QueriedMetadata.randomCurrency;

			List<Sobject> dataRowsStandard = new List<Sobject>();
			Map<String, Double> keyToPrice = new Map<String, Double>(); // key = PB Id + Prod Id + currency

			for (Integer i = 0; i < rowCount; i++)
			{
				Id productId = getForeignKeyValue(allForeignKeys, Product2.SObjectType, i);
				Id pricebookId = getForeignKeyValue(allForeignKeys, Pricebook2.SObjectType, i);

				// standard price must exist before custom price
				PricebookEntry rowStandard = TDB_RowCreator.initStandardPricebookEntry(productId);
				String standardCurrencyValue = (Userinfo.isMultiCurrencyOrganization() ? (String)rowStandard.get('CurrencyIsoCode') : '');
				addRequestedValues(rowStandard, i, requestedFieldValues);
				// only create if this is a novel currency
				if (!keyToPrice.containsKey(rowStandard.Pricebook2Id + '-' + rowStandard.Product2Id + standardCurrencyValue))
				{
					dataRowsStandard.add(rowStandard);
					keyToPrice.put(rowStandard.Pricebook2Id + '-' + rowStandard.Product2Id + standardCurrencyValue, rowStandard.UnitPrice);
				}

				PricebookEntry row = TDB_RowCreator.initCustomPricebookEntry(pricebookId, productId);
				String customCurrencyValue = (Userinfo.isMultiCurrencyOrganization() ? (String)row.get('CurrencyIsoCode') : '');
				addRequestedValues(row, i, requestedFieldValues);
				// only create if this is a novel PB/currency combination
				if (!keyToPrice.containsKey(row.Pricebook2Id + '-' + row.Product2Id + customCurrencyValue))
				{
					dataRows.add(row);
					keyToPrice.put(row.Pricebook2Id + '-' + row.Product2Id + customCurrencyValue, row.UnitPrice);
				}
			}
			insert dataRowsStandard;
			insert dataRows;
			return dataRows;
		}

	}

	private class OpportunityLineItemDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Id opportunityId = getForeignKeyValue(allForeignKeys, Opportunity.SObjectType, i);
				Id priceId = getForeignKeyValue(allForeignKeys, PricebookEntry.SObjectType, i);

				OpportunityLineItem row = TDB_RowCreator.initOpportunityLineItem(opportunityId, priceId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class LeadDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Lead row = TDB_RowCreator.initLead();
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class CaseDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Id accountId = getForeignKeyValue(allForeignKeys, Account.SObjectType, i);
				Id contactId = getForeignKeyValue(allForeignKeys, Contact.SObjectType, i);

				Case row = TDB_RowCreator.initCase(accountId, contactId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	private class ContractDataCreator extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				Id accountId = getForeignKeyValue(allForeignKeys, Account.SObjectType, i);

				Contract row = TDB_RowCreator.initContract(accountId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}

	/*
	private class DataCreatorTemplate extends VirtualDataCreator implements DataCreator
	{
		public List<Sobject> getRows(Map<Schema.SObjectType, List<Id>> allForeignKeys, Integer rowCount, Map<String, Object> requestedFieldValues)
		{
			List<Sobject> dataRows = new List<Sobject>();

			for (Integer i = 0; i < rowCount; i++)
			{
				// get corresponding FKs
				Id accountId = getForeignKeyValue(allForeignKeys, Account.SObjectType, i);

				// create new row -- passing in FKs
				MyTable row = TDB_RowCreator.initMyObject(accountId);
				addRequestedValues(row, i, requestedFieldValues);
				dataRows.add(row);
			}
			insert dataRows;
			return dataRows;
		}
	}
	*/

}
