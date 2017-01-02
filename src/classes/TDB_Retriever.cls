public with sharing class TDB_Retriever {

	// NOTE: this class is complete
	// you don't need to customize it unless you want to add features

	public static User findUserInProfile(String profileName, Set<Id> otherThanIds)
	{
		return findUserInProfile(profileName, otherThanIds, true);
	}

	public static User findUserInProfile(String profileName, Set<Id> otherThanIds, Boolean isActive)
	{
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
		List<User> matches = [SELECT Id FROM User WHERE Id NOT IN :otherThanIds AND IsActive = :isActive AND ProfileId = :p.Id LIMIT 1];

		if (matches.isEmpty())
			return null;

		return matches[0];
	}

	public static User findUserNotInProfile(String profileName, Set<Id> otherThanIds)
	{
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
		List<User> matches = [SELECT Id FROM User WHERE Id NOT IN :otherThanIds AND IsActive = false AND ProfileId != :p.Id LIMIT 1];

		if (matches.isEmpty())
			return null;

		return matches[0];
	}

}
