@isTest private class TDB_Tests {

	// NOTE: this class provides test coverage for Test Data Bundles as it comes from git
	// if you extend the tool you may need more methods

	@isTest static void getMetadata()
	{
		Map<String, String> res = TDB_Utils.getCustomMetadataMap(TDB_Constants.METADATA_MAX_INDICIES_NAME);
		System.assert(res.size() > 0);

		Map<String, sObject> contractStatues = TDB_QueriedMetadata.contractStatuses;
		String activated = TDB_QueriedMetadata.contractActivatedStatus;
		String draft = TDB_QueriedMetadata.contractDraftStatus;
		Map<String, sObject> caseStatuses = TDB_QueriedMetadata.caseStatuses;
		String opened = TDB_QueriedMetadata.caseOpenStatus;
		String closed = TDB_QueriedMetadata.caseClosedStatus;

		// could put your own values in here
		System.assert(contractStatues.size() > 0);
		System.assert(activated != null);
		System.assert(draft != null);
		System.assert(caseStatuses.size() > 0);
		System.assert(opened != null);
		System.assert(closed != null);
	}

	@isTest static void customException()
	{
		try
		{
			throw TDB_Utils.getExceptionInstance('badness');
			System.assert(false);
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}

	@isTest static void getIndividualRows()
	{
		Account a = TDB_RowCreator.createAccount();
		System.debug(a);
		Opportunity o = TDB_RowCreator.createOpportunity(a.Id);
		System.debug(o);
		Contact c = TDB_RowCreator.createContact(a.Id);
		System.debug(c);
		OpportunityContactRole cr = TDB_RowCreator.createContactRole(c.Id, o.Id);
		System.debug(cr);

		Product2 p = TDB_RowCreator.createProduct();
		System.debug(p);
		System.debug('standard pb ' + TDB_RowCreator.getStandardPricebookId());
		Pricebook2 pb = TDB_RowCreator.createPricebook();
		System.debug(pb);
		PricebookEntry stdEntry = TDB_RowCreator.createStandardPricebookEntry(p.Id);
		System.debug(stdEntry);
		PricebookEntry custEntry = TDB_RowCreator.createCustomPricebookEntry(pb.Id, p.Id);
		System.debug(custEntry);

		OpportunityLineItem oli = TDB_RowCreator.createOpportunityLineItem(o.Id, custEntry.Id);
		System.debug(oli);

		Lead l = TDB_RowCreator.createLead();
		System.debug(l);
		Case ca = TDB_RowCreator.createCase(a.Id, c.Id);
		System.debug(ca);
		Contract con = TDB_RowCreator.createContract(a.Id);
		TDB_RowCreator.activateContracts(new List<Contract>{ con });
		System.debug(con);
		Contract extraCon = TDB_RowCreator.initContract(a.Id);

		// NOTE: anything better to assert?
		System.assert(a != null);
		System.assert(o != null);
		System.assert(c != null);
		System.assert(cr != null);
		System.assert(p != null);
		System.assert(pb != null);
		System.assert(stdEntry != null);
		System.assert(custEntry != null);
		System.assert(oli != null);
		System.assert(l != null);
		System.assert(ca != null);
		System.assert(con != null);
	}

	@isTest static void getAccounts()
	{
		Integer rowCount = 3;
		List<Sobject> testRows = TDB_RowsCreator.getRows(Account.SObjectType, 3, new Map<Schema.SObjectType, List<Id>>(),
//			new Map<String, Object>{Account.SObjectType => new Map<String, Object> {'Website' => 'http://www.yahoo.com|http://www.google.com'}}
			new Map<String, Object>()
		);
		System.assertEquals(rowCount, testRows.size());
	}

	@isTest static void getTestBundles()
	{
		Map<Schema.SObjectType, List<SObject>> res1 = TDB_MyBundles.testBundle();
		System.assert(res1.size() > 0);

		Map<Schema.SObjectType, List<SObject>> res2 = TDB_MyBundles.opportunityWithLines();
		System.assert(res2.size() > 0);

		Map<Schema.SObjectType, List<SObject>> res3 = TDB_MyBundles.opportunityWithContacts();
		System.assert(res3.size() > 0);

		Map<Schema.SObjectType, List<SObject>> res4 = TDB_MyBundles.leadsFromGoogle();
		System.assert(res4.size() > 0);

		Map<Schema.SObjectType, List<SObject>> res99 = TDB_MyBundles.getBundle(
			new Map<Schema.SObjectType, Integer> {
				Opportunity.SObjectType => 1,
				OpportunityLineItem.SObjectType => 3
			},
			new Map<Schema.SObjectType, Map<String, Object>>{
			}
		);

		System.assertEquals(1, res99.get(Opportunity.SObjectType).size());
		System.assertEquals(3, res99.get(OpportunityLineItem.SObjectType).size());
	}

	@isTest static void prepRunAs()
	{
		User u1 = TDB_Retriever.findUserInProfile('System Administrator', new Set<Id>());
		User u2 = TDB_Retriever.findUserNotInProfile('System Administrator', new Set<Id>());
		User u3 = TDB_Retriever.findUserInProfile('System Administrator', new Set<Id>{ UserInfo.getUserId() });
		User u4 = TDB_Retriever.findUserNotInProfile('System Administrator', new Set<Id>{ UserInfo.getUserId() });
	}

}
