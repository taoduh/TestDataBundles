Test Data Bundles for Apex
----

Test Data Bundles makes generating data easy for Apex unit tests.  Simply request the number of rows per table you need and you'll get back everything you need.  Custom metadata specify the object dependencies.  All dependencies will be created but you'll only get back what you ask for.  

**Example:**
```sh
Map<Schema.SObjectType, List<SObject>> testOpportunity = TDB_MyBundles.getBundle(
    new Map<Schema.SObjectType, Integer> {
        Opportunity.SObjectType => 1,
        OpportunityLineItem.SObjectType => 3
    },
    new Map<Schema.SObjectType, Map<String, Object>>{ }
);
```

That call will return a map containing 1 opportunity and 3 opportunity products.  In the background an account, 3 products, and 3 pricebook entries will also be created.  If you specify those objects in the call they will be returned to you.

Feel free to create sugar methods for commonly-used bundles.

**Customzing**

You will need to do a few things to customize this tool for your org.  For each standard or custom object you need test data for:

 1. Add 2 or 3 custom metadata values.  First is  Create_Data_Order which lists the order in which rows should be created.  For instance, accounts come before contacts.  Next is Object_Dependencies which lists the tables for which there are master-detail relationships.  For instance, PricebookEntry relies on foreign keys from Product2 and Pricebook2.  Finally Other_Lookups lists lookup relationships and the tables thereof.  For instance if opportunities had a column called Secondary_Account__c, it would have a value of Opportunity:Secondary_Account__c=Account.  NOTE: in future versions of this tool, only the first metatadata row will be required, the other two will be derived.
 1. Add column lists and maps to TDB_MyColumns. fieldList is a list of fields that will get randomly generated values.  Master-detail and lookup fields should be excluded from this list.  constantValues is a map of values that should be the same for every test data row.  You can include pipe-separated values which will be assigned round-robin to the test data.  And optionally, the requiredValues list contains columns that are required by validation rule or some other mechanism than the column definition itself.  (The tool will randomly include null values for columns that are not marked as required by the metadata or this list.
 1. Add both init and a create methods in TDB_RowCreator.  Template methods exist in the bottom.  Arguments to the methods should be the parent foreign key values (the template accepts an account ID).  The init method should make use of the field lists created in the prior step.
 1. Add a DataCreator implementation in TDB_RowsCreator.  Follow the DataCreatorTemplate sample.  The parts to customize are which object foreign-keys you need to extract (the template extracts an account ID).  Then call the init method created in the prior step.  Finally, add an "else if" clause in the dataCreatorFactory method


**Roadmap Features**

 - Check size limits before picking random numeric values
 - Fix dependent picklists.  The current logic is buggy and therefore not included.
 - Create multiple profiles of data (for instance a brand new opportunity which may require certain data and a closed opportunity which may require much more data.)
 - Change constantValues maps to use describe field references instead of strings
 - Object_Dependencies and Other_Lookupsshould be derived from object describe
 - Consider moving constantValues maps to the database
 - Add hints for random values such as date = today/past/future or more specific ranges for numbers
 - Find ways to handle systemic validations such as only one contact can be primary.  What about custom validations?
