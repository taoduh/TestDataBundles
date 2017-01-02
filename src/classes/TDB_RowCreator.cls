public with sharing class TDB_RowCreator {

	// CUSTOMIZATION NOTE: for each object that is not already implmented:
	// (1) implement an init method
	// (2) implement a create method

	public static Account createAccount()
	{
		Account row = initAccount();
		insert row;
		return row;
	}
	public static Account initAccount()
	{
		Account row = new Account();
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.accountFieldList, TDB_MyColumns.accountConstantValues);
		return row;
	}

	public static Opportunity createOpportunity(Id accountId)
	{
		Opportunity row = initOpportunity(accountId);
		insert row;
		return row;
	}
	public static Opportunity initOpportunity(Id accountId)
	{
		Opportunity row = new Opportunity(AccountId = accountId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.opportunityFieldList, TDB_MyColumns.opportunityConstantValues);
		return row;
	}

	public static Contact createContact(Id accountId)
	{
		Contact row = initContact(accountId);
		insert row;
		return row;
	}
	public static Contact initContact(Id accountId)
	{
		Contact row = new Contact(AccountId = accountId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.contactFieldList, TDB_MyColumns.contactConstantValues);
		return row;
	}

	// TODO (future): only one can be primary
	public static OpportunityContactRole createContactRole(Id contactId, Id opportunityId)
	{
		OpportunityContactRole row = initContactRole(contactId, opportunityId);
		insert row;
		return row;
	}
	public static OpportunityContactRole initContactRole(Id contactId, Id opportunityId)
	{
		OpportunityContactRole row = new OpportunityContactRole(ContactId = contactId, OpportunityId = opportunityId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.contactRoleFieldList, TDB_MyColumns.contactRoleConstantValues);
		return row;
	}

	public static Product2 createProduct()
	{
		Product2 row = initProduct();
		insert row;
		return row;
	}
	public static Product2 initProduct()
	{
		Product2 row = new Product2();
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.productFieldList, TDB_MyColumns.productConstantValues);
		return row;
	}

	public static Id getStandardPricebookId()
	{
		if (Test.isRunningTest())
			return Test.getStandardPricebookId();
		else
			return [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1][0].Id;
	}

	public static Pricebook2 createPricebook()
	{
		Pricebook2 row = initPricebook();
		insert row;
		return row;
	}
	public static Pricebook2 initPricebook()
	{
		Pricebook2 row = new Pricebook2();
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.pricebookFieldList, TDB_MyColumns.pricebookConstantValues);
		return row;
	}

	public static PricebookEntry createStandardPricebookEntry(Id productId)
	{
		return createCustomPricebookEntry(getStandardPricebookId(), productId);
	}
	public static PricebookEntry initStandardPricebookEntry(Id productId)
	{
		return initCustomPricebookEntry(getStandardPricebookId(), productId);
	}
	public static PricebookEntry createCustomPricebookEntry(Id pricebookId, Id productId)
	{
		PricebookEntry row = initCustomPricebookEntry(pricebookId, productId);
		insert row;
		return row;
	}
	public static PricebookEntry initCustomPricebookEntry(Id pricebookId, Id productId)
	{
		PricebookEntry row = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.pricebookEntryFieldList, TDB_MyColumns.pricebookEntryConstantValues);
		return row;
	}

	public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id pricebookEntryId)
	{
		OpportunityLineItem row = initOpportunityLineItem(opportunityId, pricebookEntryId);
		insert row;
		return row;
	}
	public static OpportunityLineItem initOpportunityLineItem(Id opportunityId, Id pricebookEntryId)
	{
		OpportunityLineItem row = new OpportunityLineItem(OpportunityId = opportunityId, PricebookEntryId = pricebookEntryId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.opportunityLineItemFieldList, TDB_MyColumns.opportunityLineItemConstantValues, TDB_MyColumns.opportunityLineItemRequiredValues);
		return row;
	}

	public static Lead createLead()
	{
		Lead row = initLead();
		insert row;
		return row;
	}
	public static Lead initLead()
	{
		Lead row = new Lead();
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.leadFieldList, TDB_MyColumns.leadConstantValues);
		return row;
	}

	public static Case createCase(Id accountId, Id contactId)
	{
		Case row = initCase(accountId, contactId);
		insert row;
		return row;
	}
	public static Case initCase(Id accountId, Id contactId)
	{
		Case row = new Case(AccountId = accountId, ContactId = contactId);

		// default to open status unless a value is specified
		if (!TDB_MyColumns.caseConstantValues.containsKey(Case.Status))
			row.Status = TDB_QueriedMetadata.caseOpenStatus;

		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.caseFieldList, TDB_MyColumns.caseConstantValues);
		return row;
	}

	public static Contract createContract(Id accountId)
	{
		// if a status was specified, hold on to it since initial status must be draft
		String finalStatusValue;
		if (TDB_MyColumns.contractConstantValues.containsKey(Contract.Status))
		{
			// TODO (future): handle multiple status values
			finalStatusValue = (String)TDB_MyColumns.contractConstantValues.get(Contract.Status);

			// if the final value is draft, no further work is needed
			if (TDB_QueriedMetadata.contractStatuses.get(finalStatusValue).get('StatusCode') == 'Draft')
				finalStatusValue = null;
		}
		Contract row = initContract(accountId);
		insert row;

		if (finalStatusValue != null)
		{
			row.Status = finalStatusValue;
			update row;
		}

		return row;
	}
	public static Contract initContract(Id accountId)
	{
		// if the list of random fields inclues status, put a draft value in here (rather than a random value)
		Integer indexOfStatusField = TDB_Utils.listIndexOf(TDB_MyColumns.contractFieldList, Contract.Status);
		if (indexOfStatusField > -1)
		{
			TDB_MyColumns.contractFieldList.remove(indexOfStatusField);
			TDB_MyColumns.contractConstantValues.put(Contract.Status, TDB_QueriedMetadata.contractDraftStatus);
		}

		Contract row = new Contract(AccountId = accountId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.contractFieldList, TDB_MyColumns.contractConstantValues);

		return row;
	}

	// NOTE: contracts are special as they must be activated
	// here is a bare-bones method to do so if you need it
	// you could call it from TDB_RowsCreator if necessary
	public static void activateContracts(List<Contract> contracts)
	{
		for (Contract c : contracts)
			c.Status = TDB_QueriedMetadata.contractActivatedStatus;
		update contracts;
	}

	/*
	public static Opportunity createMyObject(Id accountId)
	{
		MyObject row = initMyObject(accountId);
		insert row;
		return row;
	}
	public static Opportunity initMyObject(Id accountId)
	{
		MyObject row = new MyObject(AccountId = accountId);
		TDB_ValueGenerator.assignValues(row, TDB_MyColumns.myObjectFieldList, TDB_MyColumns.myObjectConstantValues);
		return row;
	}
	*/

}
