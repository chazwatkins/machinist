public with sharing class Machinist_Controller {

  private static Map<String, SObjectType> sObjectTypesByName =
      Schema.getGlobalDescribe();

  private static Map<String, DescribeSObjectResult> sObjectDescribeByName =
      new Map<String, DescribeSObjectResult>();

  @AuraEnabled
  public static MachineEditor newMachine() {
    return new MachineEditor(
        Machinist.newMachine(),
        getSObjectTypeOptions()
    );
  }

  @AuraEnabled
  public static void createMachine(Machinist.Machine machine) {
    Machinist.createMachine(machine);
  }

  @AuraEnabled(Cacheable=true)
  public static Machinist.Machine getMachine(String machineName) {
    return Machinist.getMachine(machineName);
  }

  @AuraEnabled(Cacheable=false)
  public static SObjectTypeDetails getSObjectTypeDetails(String sObjTypeName) {
    return new SObjectTypeDetails(
        getSObjectFields(sObjTypeName),
        getActiveSObjectRecordTypes(sObjTypeName)
    );
  }

  private static SelectOption[] getSObjectTypeOptions() {
    SelectOption[] sObjects = new List<SelectOption>();
    for(SObjectType sObjType : sObjectTypesByName.values()) {
      String sObjTypeName = String.valueOf(sObjType);
      DescribeSObjectResult sObjDetails = getSObjectDescribe(sObjTypeName);
      sObjects.add(new SelectOption(sObjDetails.label, sObjDetails.name));
    }

    return sObjects;
  }

  private static SelectOption[] getSObjectFields(String sObjectApiName) {
    SelectOption[] sObjectFields = new List<SelectOption>();

    DescribeSObjectResult sObjDetails = getSObjectDescribe(sObjectApiName);
    for(SObjectField field : sObjDetails.fields.getMap().values()) {
      DescribeFieldResult fieldDetails = field.getDescribe();

      String fieldLabel =
          String.format(
              '{0} ({1})',
              new List<String>{
                  fieldDetails.label,
                  fieldDetails.type.name().toLowerCase()
              }
          );

      sObjectFields.add(
          new SelectOption(
              fieldLabel,
              fieldDetails.name
          )
      );
    }

    return sObjectFields;
  }

  private static SelectOption[] getActiveSObjectRecordTypes(String sObjectApiName) {
    SelectOption[] recordTypes = new List<SelectOption>();

    SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectApiName.toLowerCase());
    for(RecordTypeInfo recordType : sObjType.getDescribe().recordTypeInfos) {
      if(!recordType.active || recordType.isMaster()) {
        continue;
      }

      recordTypes.add(new SelectOption(recordType.name, recordType.developerName));
    }

    return recordTypes;
  }

  private static DescribeSObjectResult getSObjectDescribe(String sObjTypeName) {
    String sObjTypeKey = sObjTypeName.toLowerCase();
    if(!sObjectDescribeByName.keySet().contains(sObjTypeKey)) {
      SObjectType sObjType = sObjectTypesByName.get(sObjTypeKey);
      sObjectDescribeByName.put(sObjTypeName, sObjType.getDescribe());
    }

    return sObjectDescribeByName.get(sObjTypeName);
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

  public class MachineEditor {
    @AuraEnabled
    public Machinist.Machine machine;
    @AuraEnabled
    public SelectOption[] sObjectTypeOptions;

    private MachineEditor(
        Machinist.Machine machine,
        SelectOption[] sObjectTypeOptions
    ) {
      this.machine = machine;
      this.sObjectTypeOptions = sObjectTypeOptions;
    }
  }

  public class SObjectTypeDetails {
    @AuraEnabled
    public SelectOption[] sObjectFieldOptions;
    @AuraEnabled
    public SelectOption[] recordTypeOptions;

    private SObjectTypeDetails(
        SelectOption[] sObjectFieldOptions,
        SelectOption[] recordTypeOptions
    ) {
      this.sObjectFieldOptions = sObjectFieldOptions;
      this.recordTypeOptions = recordTypeOptions;
    }
  }
}
