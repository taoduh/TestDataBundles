public with sharing class TDB_MyBundles {

	// CUSTOMIZATION NOTE: this is a place to add sugar methods for common data bundles
	// three examples are provided (testBundle, leadsFromGoogle and opportunityWithLines)
	// the base method (getBundle) can be used for generic data requests


	// TODO (future): use field references instead of strings for second map

	// Example Usage:
	//
	// TDB_BundleCreator tdb = new TDB_BundleCreator();
	// Map<String, List<SObject>> data = tdb.getQuoteBundle();
	// System.debug(data);
	// List<Product2> testProducts = data.get('Product2');
	// List<Quote> testQuotes = data.get('Quote');

	// simple pass-through
	public static Map<Schema.SObjectType, List<SObject>> getBundle(Map<Schema.SObjectType, Integer> requestedRows, Map<Schema.SObjectType, Map<String, Object>> requestedFieldValues)
	{
		// NOTE: if you need to load custom settings, you can do it here or in a sugar method below
		//TDB_RowsCreator.loadCustomSettings();

		TDB_BundleCreator bundles = new TDB_BundleCreator();
		return bundles.getBundle(requestedRows, requestedFieldValues);
	}

	// a sample call to getBundle()
	public static Map<Schema.SObjectType, List<SObject>> testBundle()
	{
		TDB_BundleCreator bundles = new TDB_BundleCreator();
		return bundles.getBundle(
			new Map<Schema.SObjectType, Integer> {
				Account.SObjectType => 1,
				Opportunity.SObjectType => 2
			},
			new Map<Schema.SObjectType, Map<String, Object>>{
				Account.SObjectType => new Map<String, Object> {'Website' => 'http://www.yahoo.com|http://www.google.com'},
				Opportunity.SObjectType => new Map<String, Object> {'Description' => 'TDB'}
			}
		);
	}

	public static Map<Schema.SObjectType, List<SObject>> leadsFromGoogle()
	{
		TDB_BundleCreator bundles = new TDB_BundleCreator();
		return bundles.getBundle(
			new Map<Schema.SObjectType, Integer> {
				Lead.SObjectType => 200
			},
			new Map<Schema.SObjectType, Map<String, Object>>{
				Lead.SObjectType => new Map<String, Object> {'Website' => 'http://www.google.com', 'Company' => 'Google'}
			}
		);
	}

	public static Map<Schema.SObjectType, List<SObject>> opportunityWithLines()
	{
		TDB_BundleCreator bundles = new TDB_BundleCreator();
		return bundles.getBundle(
			new Map<Schema.SObjectType, Integer> {
				Opportunity.SObjectType => 1,
				OpportunityLineItem.SObjectType => 2
			},
			new Map<Schema.SObjectType, Map<String, Object>>{
			}
		);
	}

	public static Map<Schema.SObjectType, List<SObject>> opportunityWithContacts()
	{
		TDB_BundleCreator bundles = new TDB_BundleCreator();
		return bundles.getBundle(
			new Map<Schema.SObjectType, Integer> {
				Opportunity.SObjectType => 1,
				Contact.SObjectType => 2,
				OpportunityContactRole.SObjectType => 2
			},
			new Map<Schema.SObjectType, Map<String, Object>>{
			}
		);
	}
}
