public with sharing class TDB_QueriedMetadata {

	// NOTE: this class is complete
	// you don't need to customize it unless you want to add features

	// if this org supports currencies, get a random one for this transaction
	public static String randomCurrency
	{
		get
		{
			if (randomCurrency == null)
			{
				if (Schema.getGlobalDescribe().get('CurrencyType') != null)
				{
					List<sObject> supportedISOCodes = Database.query('SELECT ISOCode FROM CurrencyType WHERE IsActive = true');
					if (supportedISOCodes.size() == 0)
						randomCurrency = '';

					Integer randomCurrencyIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), supportedISOCodes.size());
					randomCurrency = (String)supportedISOCodes.get(randomCurrencyIndex).get('ISOCode');
				}
				else
				{
					randomCurrency = '';
				}
			}
			return randomCurrency;

		}
		private set;
	}

	/////////////////////////////////////////////////////////////////////////
	// START contract status methods
	/////////////////////////////////////////////////////////////////////////
	public static String contractDraftStatus
	{
		get
		{
			if (contractDraftStatus == null)
				retrieveContractStatuses();
			return contractDraftStatus;
		}
		private set;
	}

	public static String contractActivatedStatus
	{
		get
		{
			if (contractActivatedStatus == null)
				retrieveContractStatuses();
			return contractActivatedStatus;
		}
		private set;
	}

	public static Map<String, sObject> contractStatuses
	{
		get
		{
			if (contractStatuses == null)
				retrieveContractStatuses();
			return contractStatuses;
		}
		private set;
	}

	private static void retrieveContractStatuses()
	{
		List<ContractStatus> rawStatuses = [SELECT MasterLabel, StatusCode FROM ContractStatus];
		contractStatuses = TDB_Utils.mapByString(rawStatuses, 'MasterLabel');

		for (ContractStatus s : rawStatuses)
		{
			if (s.StatusCode == 'Draft')
				contractDraftStatus = s.MasterLabel;
			if (s.StatusCode == 'Activated')
				contractActivatedStatus = s.MasterLabel;
		}
	}

	/////////////////////////////////////////////////////////////////////////
	// END contract status methods
	/////////////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////////////
	// START case status methods
	/////////////////////////////////////////////////////////////////////////
	public static String caseOpenStatus
	{
		get
		{
			if (caseOpenStatus == null)
				retrieveCaseStatuses();
			return caseOpenStatus;
		}
		private set;
	}

	public static String caseClosedStatus
	{
		get
		{
			if (caseClosedStatus == null)
				retrieveCaseStatuses();
			return caseClosedStatus;
		}
		private set;
	}

	public static Map<String, sObject> caseStatuses
	{
		get
		{
			if (caseStatuses == null)
				retrieveCaseStatuses();
			return caseStatuses;
		}
		private set;
	}

	private static void retrieveCaseStatuses()
	{
		List<CaseStatus> rawStatuses = [SELECT MasterLabel, IsClosed FROM CaseStatus];
		caseStatuses = TDB_Utils.mapByString(rawStatuses, 'MasterLabel');

		for (CaseStatus s : rawStatuses)
		{
			if (s.IsClosed)
				caseOpenStatus = s.MasterLabel;
			else
				caseClosedStatus = s.MasterLabel;
		}
	}
	/////////////////////////////////////////////////////////////////////////
	// END case status methods
	/////////////////////////////////////////////////////////////////////////

}
