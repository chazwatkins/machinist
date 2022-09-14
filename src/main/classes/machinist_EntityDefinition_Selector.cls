public inherited sharing class machinist_EntityDefinition_Selector {

    public static EntityDefinition[] getAllSObjectTypes() {
        return [
            SELECT
                MasterLabel,
                QualifiedApiName
            FROM EntityDefinition
            WHERE IsCustomizable = TRUE
                AND IsApexTriggerable = TRUE
                AND DurableId IN (
                    SELECT
                        EntityDefinitionId
                    FROM FieldDefinition
                    WHERE DataType = 'Picklist'
            )
            ORDER BY MasterLabel ASC
        ];
    }

    public static FieldDefinition[] getSObjectTypePicklistFields(
        String sObjTypeApiName
    ) {
        return [
            SELECT
                MasterLabel,
                QualifiedApiName,
                DataType
            FROM FieldDefinition
            WHERE EntityDefinition.QualifiedApiName = :sObjTypeApiName
            AND DataType = 'Picklist'
            ORDER BY MasterLabel ASC
        ];
    }

    public static EntityDefinition[] searchByLabel(String searchTerm) {
        return ((EntityDefinition[][])[
            FIND :searchTerm + '*'
            IN NAME FIELDS
            RETURNING EntityDefinition(
                MasterLabel,
                QualifiedApiName
                WHERE IsCustomizable = TRUE
                ORDER BY MasterLabel ASC
            )
        ]).get(0);
    }

    public static FieldDefinition[] searchPicklistFieldsBySObjectAndLabel(
        String searchTerm,
        String sObjTypeApiName
    ) {
        return ((FieldDefinition[][])[
            FIND :searchTerm + '*'
            IN NAME FIELDS
            RETURNING FieldDefinition(
                MasterLabel,
                QualifiedApiName,
                DataType
                WHERE EntityDefinition.QualifiedApiName = :sObjTypeApiName
                    AND DataType = 'Picklist'
                ORDER BY MasterLabel ASC
            )
        ]).get(0);
    }

    public static RecordType[] selectRecordTypeBySObjectName(String sObjectName) {
        return [
            SELECT
                Name,
                DeveloperName
            FROM RecordType
            WHERE SobjectType = :sObjectName
                AND IsActive = TRUE
        ];
    }
}