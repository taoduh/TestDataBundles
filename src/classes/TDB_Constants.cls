public with sharing class TDB_Constants
{
	// NOTE: this class is complete
	// you don't need to customize it unless you want to add features

	// Names of metadata rows in TDB_Parameter
	public static String METADATA_MAX_INDICIES_NAME = 'Max_Indicies';
	public static String METADATA_OBJ_DEPENDENCIES_NAME = 'Object_Dependencies';
	public static String METADATA_CREATE_ORDER_NAME = 'Create_Data_Order';
	public static String METADATA_OTHER_LOOKUPS_NAME = 'Other_Lookups';

	// NOTE: integers are fun so this percentage goes from 0 to 100
	// e.g. 15 = 15% chance
	public static Integer CHANCE_FIELD_BLANK = 10;
}
