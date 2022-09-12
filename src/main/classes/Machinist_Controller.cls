public with sharing class Machinist_Controller {

//  @AuraEnabled(Cacheable=true)
//  public static Machinist.Machine getMachine(String machineName) {
//    return Machinist.getMachine(machineName);
//  }
//
//  @AuraEnabled(Cacheable=true)
//  public static SelectOption[] getAllSObjects() {
//    SelectOption[] sObjects = new List<SelectOption>();
//    for(SObjectType sObjType : Schema.getGlobalDescribe().values()) {
//      Schema.DescribeSObjectResult result = sObjType.getDescribe();
//      sObjects.add(new SelectOption(result.label, result.name));
//    }
//
//    return sObjects;
//  }
//
//  @AuraEnabled
//  public static SelectOption[] getActiveSObjectRecordTypes(String sObjectApiName) {
//    SelectOption[] recordTypes = new List<SelectOption>();
//
//    SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectApiName.toLowerCase());
//    for(RecordTypeInfo recordType : sObjType.getDescribe().recordTypeInfos) {
//      if(!recordType.active || recordType.isMaster()) {
//        continue;
//      }
//
//      recordTypes.add(new SelectOption(recordType.name, recordType.developerName));
//    }
//
//    return recordTypes;
//  }
//
//  public class SelectOption {
//    @AuraEnabled
//    public String name;
//    @AuraEnabled
//    public String value;
//
//    public SelectOption(String name, String value) {
//      this.name = name;
//      this.value = value;
//    }
//  }
}
