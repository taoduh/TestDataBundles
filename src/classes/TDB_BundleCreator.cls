public with sharing class TDB_BundleCreator {

	// NOTE: this class is complete
	// you don't need to customize it unless you want to add features

	// TODO (future): can I refactor out the dependencies bit?  is the creation order metadata all I really need?
	// TODO (future): custom lookups, I have the field-table mapping but need to figure out how to tie it up

	// stored in metadata, the order in which test data is created
	// e.g. Accounts before Opportunities
	private List<Schema.SObjectType> createDataOrder = new List<Schema.SObjectType>();
	// stored in metadata, the dependencies needed to create a row of data
	// e.g. a Quote row needs Account, Opportunity and Pricebook rows to be created first
	private Map<Schema.SObjectType, List<Schema.SObjectType>> allDependencies = new Map<Schema.SObjectType, List<Schema.SObjectType>>();
	// stored in metadata, the dependencies needed to create a row of data
	// e.g. a Quote row needs Account, Opportunity and Pricebook rows to be created first
	private Map<Schema.SObjectType, Map<String, Schema.SObjectType>> otherLookups = new Map<Schema.SObjectType, Map<String, Schema.SObjectType>>();
	// for those times when names are easy to get but types are needed
	private Map<String, Schema.SObjectType> configNameToSchemaName = new Map<String, Schema.SObjectType>();

	public TDB_BundleCreator()
	{
		for (Schema.SObjectType typ : Schema.getGlobalDescribe().values())
			configNameToSchemaName.put(typ.getDescribe().getName(), typ.getDescribe().getSobjectType());

		// determine count of metadata rows
		Map<String, String> config = TDB_Utils.getCustomMetadataMap(TDB_Constants.METADATA_MAX_INDICIES_NAME);
		Integer orderMaxIndex = Integer.valueOf(config.get(TDB_Constants.METADATA_CREATE_ORDER_NAME));
		Integer dependencyMaxIndex = Integer.valueOf(config.get(TDB_Constants.METADATA_OBJ_DEPENDENCIES_NAME));
		Integer otherLookupMaxIndex = Integer.valueOf(config.get(TDB_Constants.METADATA_OTHER_LOOKUPS_NAME));

		// retrieve/parse row creation order
		String rawOrder = '';
		for (Integer i = 1; i <= orderMaxIndex; i++)
		{
			config = TDB_Utils.getCustomMetadataMap(TDB_Constants.METADATA_CREATE_ORDER_NAME + i);
			rawOrder += ',' + config.get('Order');
		}

		for (String s : rawOrder.split(','))
			if (configNameToSchemaName.containsKey(s))
				createDataOrder.add(configNameToSchemaName.get(s));
		System.debug('TDB create data order ' + createDataOrder);

		// retrieve/parse data dependency information
		for (Integer i = 1; i <= dependencyMaxIndex; i++)
		{
			config = TDB_Utils.getCustomMetadataMap(TDB_Constants.METADATA_OBJ_DEPENDENCIES_NAME + i);
			for (String k : config.keySet())
				if (configNameToSchemaName.containsKey(k))
				{
					allDependencies.put(configNameToSchemaName.get(k), new List<Schema.SObjectType>());
					for (String s : config.get(k).split(','))
					{
						if (configNameToSchemaName.containsKey(s))
							allDependencies.get(configNameToSchemaName.get(k)).add(configNameToSchemaName.get(s));
					}
				}
		}
		for (String t : rawOrder.split(','))
			if (configNameToSchemaName.containsKey(t))
				if (!allDependencies.containsKey(configNameToSchemaName.get(t)))
					allDependencies.put(configNameToSchemaName.get(t), new List<Schema.SObjectType>());
		System.debug('TDB data creation dependencies ' + allDependencies);

		// retrieve/parse other lookup object types
		for (Integer i = 1; i <= otherLookupMaxIndex; i++)
		{
			config = TDB_Utils.getCustomMetadataMap(TDB_Constants.METADATA_OTHER_LOOKUPS_NAME + i);
			for (String tableName : config.keySet())
			{
				Schema.SObjectType table = configNameToSchemaName.get(tableName);
				if (!otherLookups.containsKey(table))
					otherLookups.put(table, new Map<String, Schema.SObjectType>());

				// value is comma-separated foreign key = table name, e.g. Secondary_Account__c=Account,Tertiary_Account__c=Account
				for (String relation : config.get(tableName).split(','))
				{
					List<String> pieces = relation.split('=');
					String fkName = pieces.get(0);
					Schema.SObjectType referenceTable = configNameToSchemaName.get(pieces.get(1));

					otherLookups.get(table).put(fkName, referenceTable);
				}
			}
		}
		System.debug('TDB other lookups ' + otherLookups);
	}

	// keep track of the data tables actually requested
	// that way we won't return dependent objects not needed by the client
	Set<Schema.SObjectType> originallyRequestedTables;
	// test data that will be returned to the client
	Map<Schema.SObjectType, List<SObject>> data;


	// base method for this class
	// requested rows is how many test data rows for which tables
	// requested field values is specific values that should be populated for a given table above and beyond the defaults set in TestData
	public Map<Schema.SObjectType, List<SObject>> getBundle(Map<Schema.SObjectType, Integer> requestedRows, Map<Schema.SObjectType, Map<String, Object>> requestedFieldValues)
	{
		data = new Map<Schema.SObjectType, List<SObject>>();

		addDependencies(requestedRows, requestedFieldValues);
		validateCounts(requestedRows);
		System.debug('TDB: will create rows in ' + requestedRows.keySet());

		createDataInOrder(requestedRows, requestedFieldValues);

		removeUnrequestedDependencies();

		return data;
	}


	// run through the configured order of creation and create test data rows
	private void createDataInOrder(Map<Schema.SObjectType, Integer> requestedRows, Map<Schema.SObjectType, Map<String, Object>> requestedFieldValues)
	{
		for (Schema.SObjectType table : createDataOrder)
		{
			if (requestedRows.containsKey(table))
			{
				List<Sobject> testRows = TDB_RowsCreator.getRows(table, requestedRows.get(table), getForeignKeys(table), requestedFieldValues.get(table));
				System.debug('TDB: creating ' + requestedRows.get(table) + ' rows in ' + table);
				data.put(table, testRows);
			}
		}
	}

	// given the metadata list of table dependencies and the data created so far
	// create a list of FK Ids to be used in the creation of rows in table
	private Map<Schema.SObjectType, List<Id>> getForeignKeys(Schema.SObjectType table)
	{
		Map<Schema.SObjectType, List<Id>> foreignKeyLists = new Map<Schema.SObjectType, List<Id>>();

		List<Schema.SObjectType> foreignKeys = allDependencies.get(table);
		if (foreignKeys.size() == 0) return new Map<Schema.SObjectType, List<Id>>();

		for (Schema.SObjectType fk : foreignKeys)
		{
			List<Sobject> parentObjects = data.get(fk);
			if (parentObjects.size() == 0)
				throw TDB_Utils.getExceptionInstance('Unable to set foreign keys to ' + fk + ' from ' + table);

			List<Id> keyList = new List<Id>();
			for (Sobject so : parentObjects)
				keyList.add(so.Id);
			foreignKeyLists.put(fk, keyList);
		}

		return foreignKeyLists;
	}

	// if a requested row has a dependency that wasn't passed in, add it to the list of test data here
	private void addDependencies(Map<Schema.SObjectType, Integer> requestedRows, Map<Schema.SObjectType, Map<String, Object>> requestedFieldValues)
	{
		// first save the requested data rows so we don't return too much
		originallyRequestedTables = new Set<Schema.SObjectType>();
		for (Schema.SObjectType table : requestedRows.keySet())
			originallyRequestedTables.add(table);

		// loop through until we don't find another new dependency
		// e.g. first time through we might find we need a Contact row.  Second time Account and then no more
		Boolean dependencyAdded = true;
		while (dependencyAdded)
		{
			dependencyAdded = false;
			for (Schema.SObjectType child : requestedRows.keySet())
			{
				for (Schema.SObjectType fk : allDependencies.get(child))
				{
					if (!requestedRows.containsKey(fk))
					{
						requestedRows.put(fk, 1);
						requestedFieldValues.put(fk, new Map<String, Object>());
						dependencyAdded = true;
					}
				}
			}
		}
	}

	// make sure length on fk rows is >= child length (one fk per child row) or = 1 (same fk on all children) or = an evenly divisible number (cycle through fks evenly)
	private void validateCounts(Map<Schema.SObjectType, Integer> requestedRows)
	{
		for (Schema.SObjectType child : requestedRows.keySet())
		{
			Integer childLength = requestedRows.get(child);
			for (Schema.SObjectType fk : allDependencies.get(child))
			{
				Integer foreignLength = requestedRows.get(fk);
				if (foreignLength != 1 && foreignLength < childLength && Math.mod(childLength, foreignLength) != 0)
					throw TDB_Utils.getExceptionInstance(
						'Request was for ' + childLength + ' rows of ' + child + ' and ' + foreignLength + ' rows of ' + fk +
						'.  There is no obvious way of mapping the ' + fk + ' keys.  Please change the number of ' + fk + ' rows to either 1 or at least ' + childLength
					);
			}
		}
	}

	// if a dependency was created but not requested, remove it from result
	private void removeUnrequestedDependencies()
	{
		for (Schema.SObjectType table : data.keySet())
		{
			if (!originallyRequestedTables.contains(table))
				data.remove(table);
		}
	}

}
