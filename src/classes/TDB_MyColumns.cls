public with sharing class TDB_MyColumns {

	// CUSTOMIZATION NOTE: for each object that is not already implmented:
	// (1) create a fieldList of values that should be randomly generated (exclude all master-detail and lookup fields)
	// (2) create a constantValues map of values that should be the same for all test data rows
	// (3 - optional)  create an itemRequiredValues list of fields that are required but not marked as required in the schema

	// NOTE: don't try to include lookup fields in the lists here
	// that can be handled in the bundle class' getRows() method

	// handling record type IDs
	/*
	public static final Map<String, Schema.RecordTypeInfo> OPPORTUNITYRECORDTYPEBYNAMEMAP = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
	public static final String OPPORTUNITY_RECORDTYPENAME_STANDARD = 'Standard';
	Id opptRT = OPPORTUNITYRECORDTYPEBYNAMEMAP.get(OPPORTUNITY_RECORDTYPENAME_STANDARD).RecordTypeId;
	*/

	// TODO (future): constant value maps can be database-driven
	// TODO (future): hints for random numbers (e.g. dates only in future, numbers in a range)

	/////////////////////////////////////////////////////////////////////////
	// ACCOUNT
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> accountFieldList =
		new List<Schema.SObjectField> {
			Account.Name,
			Account.Type,
			Account.BillingStreet,
			Account.BillingCity,
			Account.BillingPostalCode,
			Account.BillingState,
			Account.BillingCountry,
			Account.Website
		};
	public static Map<Schema.SObjectField, Object> accountConstantValues =
		new Map<Schema.SObjectField, Object> {
			Account.Rating => 'Warm',
			Account.Tradestyle => 'Blustery'
		};

	/////////////////////////////////////////////////////////////////////////
	// OPPORTUNITY
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> opportunityFieldList =
		new List<Schema.SObjectField> {
			Opportunity.Name,
			Opportunity.StageName,
			Opportunity.CloseDate,
			Opportunity.Amount
		};
	public static Map<Schema.SObjectField, Object> opportunityConstantValues =
		new Map<Schema.SObjectField, Object> {
		};

	/////////////////////////////////////////////////////////////////////////
	// CONTACT
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> contactFieldList =
		new List<Schema.SObjectField> {
			Contact.FirstName,
			Contact.LastName,
			Contact.Email,
			Contact.Phone
		};
	public static Map<Schema.SObjectField, Object> contactConstantValues =
		new Map<Schema.SObjectField, Object> {
		};

	/////////////////////////////////////////////////////////////////////////
	// CONTACT ROLE
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> contactRoleFieldList =
		new List<Schema.SObjectField> {
		};
	public static Map<Schema.SObjectField, Object> contactRoleConstantValues =
		new Map<Schema.SObjectField, Object> {
			OpportunityContactRole.IsPrimary => false
		};

	/////////////////////////////////////////////////////////////////////////
	// PRODUCT
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> productFieldList =
		new List<Schema.SObjectField> {
			Product2.ProductCode,
			Product2.Name,
			Product2.Description
		};
	public static Map<Schema.SObjectField, Object> productConstantValues =
		new Map<Schema.SObjectField, Object> {
			Product2.IsActive => true
		};

	/////////////////////////////////////////////////////////////////////////
	// PRICEBOOK
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> pricebookFieldList =
		new List<Schema.SObjectField> {
			Pricebook2.Name
		};
	public static Map<Schema.SObjectField, Object> pricebookConstantValues =
		new Map<Schema.SObjectField, Object> {
			Pricebook2.IsActive => true
		};

	/////////////////////////////////////////////////////////////////////////
	// PRICEBOOK ENTRY
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> pricebookEntryFieldList =
		new List<Schema.SObjectField> {
			PricebookEntry.UnitPrice
		};
	public static Map<Schema.SObjectField, Object> pricebookEntryConstantValues =
		new Map<Schema.SObjectField, Object> {
			PricebookEntry.IsActive => true
		};

	/////////////////////////////////////////////////////////////////////////
	// OPPORTUNITY PRODUCT
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> opportunityLineItemFieldList =
		new List<Schema.SObjectField> {
			OpportunityLineItem.Quantity,
			OpportunityLineItem.UnitPrice
		};
	public static Map<Schema.SObjectField, Object> opportunityLineItemConstantValues =
		new Map<Schema.SObjectField, Object> {
		};
	public static Set<Schema.SObjectField> opportunityLineItemRequiredValues =
		new Set<Schema.SObjectField> {
			OpportunityLineItem.UnitPrice
		};

	/////////////////////////////////////////////////////////////////////////
	// CASE
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> caseFieldList =
		new List<Schema.SObjectField> {
			Case.Subject,
			Case.Description,
			Case.Status,
			Case.Origin,
			Case.Type
		};
	public static Map<Schema.SObjectField, Object> caseConstantValues =
		new Map<Schema.SObjectField, Object> {
		};

	/////////////////////////////////////////////////////////////////////////
	// CONTRACT
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> contractFieldList =
		new List<Schema.SObjectField> {
			Contract.StartDate,
			Contract.ContractTerm
		};
	public static Map<Schema.SObjectField, Object> contractConstantValues =
		new Map<Schema.SObjectField, Object> {
		};

	/////////////////////////////////////////////////////////////////////////
	// LEAD
	/////////////////////////////////////////////////////////////////////////
	public static List<Schema.SObjectField> leadFieldList =
		new List<Schema.SObjectField> {
			Lead.FirstName,
			Lead.LastName,
			Lead.Email,
			Lead.Phone,
			Lead.Company,
			Lead.Status
		};
	public static Map<Schema.SObjectField, Object> leadConstantValues =
		new Map<Schema.SObjectField, Object> {
		};

		/////////////////////////////////////////////////////////////////////////
		// MY OBJECT
		/////////////////////////////////////////////////////////////////////////
		/*
		public static List<Schema.SObjectField> myObjectFieldList =
			new List<Schema.SObjectField> {
				MyObject.Name,
				MyObject.Description
			};
		public static Map<Schema.SObjectField, Object> myObjectConstantValues =
			new Map<Schema.SObjectField, Object> {
				MyObject.Description => 'Describe me'
			};
		public static Set<Schema.SObjectField> myObjectRequiredValues =
			new Set<Schema.SObjectField> {
				MyObject.Description
			};
		*/

}
