public with sharing class Machinist_Controller {
  @AuraEnabled
  public static machinist_Machine__c createMachine(String machineConfig) {
    machinist_Machine__c newMachine =
        (machinist_Machine__c) JSON.deserialize(machineConfig, machinist_Machine__c.class);
    return Machinist.createMachine(newMachine);
  }

  @AuraEnabled(Cacheable=true)
  public static machinist_Machine__c getMachine(String machineId) {
    try {
      return Machinist.getMachine((Id)machineId);
    } catch(Exception e) {
      return Machinist.newMachine();
    }
  }

  @AuraEnabled(Cacheable=true)
  public static SelectOption[] getSObjectTypes() {
    SelectOption[] sObjectOptions = new List<SelectOption>();

    EntityDefinition[] entityDefinitions =
        machinist_EntityDefinition_Selector.getAllSObjectTypes();
    for(EntityDefinition entityDefinition : entityDefinitions) {
      sObjectOptions.add(
          new SelectOption(
              entityDefinition.MasterLabel,
              entityDefinition.QualifiedApiName
          )
      );
    }

    return sObjectOptions;
  }

  @AuraEnabled(Cacheable=true)
  public static SObjectTypeDetails getSObjectDetails(String sObjTypeName) {
    return new SObjectTypeDetails(
        getSObjectPicklistFields(sObjTypeName),
        getSObjectRecordTypes(sObjTypeName)
    );
  }


  private static SelectOption[] getSObjectPicklistFields(String sObjTypeName) {
    SelectOption[] fieldOptions = new List<SelectOption>();

    FieldDefinition[] fieldDefinitions =
        machinist_EntityDefinition_Selector.getSObjectTypePicklistFields(sObjTypeName);
    for(FieldDefinition fieldDefinition : fieldDefinitions) {
      fieldOptions.add(
          new SelectOption(
              fieldDefinition.MasterLabel,
              fieldDefinition.QualifiedApiName
          )
      );
    }

    return fieldOptions;
  }

  private static SelectOption[] getSObjectRecordTypes(String sObjTypeName) {
    RecordType[] recordTypeRecords = [
        SELECT
            Name,
            Id
        FROM RecordType
        WHERE SobjectType = :sObjTypeName
        AND IsActive = TRUE
    ];

    SelectOption[] recordTypes = new List<SelectOption>();

    for(RecordType record : recordTypeRecords) {
      recordTypes.add(
          new SelectOption(record.Name, record.Id)
      );
    }

    return recordTypes;
  }


  public class SelectOption {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    public SelectOption(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  public class SObjectTypeDetails {
    @AuraEnabled
    public SelectOption[] sObjectFields;
    @AuraEnabled
    public SelectOption[] recordTypes;

    private SObjectTypeDetails(
        SelectOption[] sObjectFields,
        SelectOption[] recordTypes
    ) {
      this.sObjectFields = sObjectFields;
      this.recordTypes = recordTypes;
    }
  }
}
