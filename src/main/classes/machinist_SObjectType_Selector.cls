public inherited sharing class machinist_SObjectType_Selector {

    public static EntityDefinition[] searchByLabel(String label) {
        return ((EntityDefinition[][])[
            FIND :label
            IN NAME FIELDS
            RETURNING EntityDefinition(MasterLabel, QualifiedApiName ORDER BY MasterLabel ASC)
        ]).get(0);
    }

    public static FieldDefinition[] searchBySObjectTypeAndLabel(
        String sObjTypeApiName,
        String fieldLabel
    ) {
        return ((FieldDefinition[][])[
            FIND :fieldLabel
            IN NAME FIELDS
            RETURNING FieldDefinition(
                MasterLabel,
                QualifiedApiName
                WHERE EntityDefinition.QualifiedApiName = :sObjTypeApiName
                ORDER BY MasterLabel ASC
            )
        ]).get(0);
    }
}