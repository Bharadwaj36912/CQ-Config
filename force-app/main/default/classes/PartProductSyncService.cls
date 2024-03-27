public class PartProductSyncService {
    public static void synchronizePartsAndProducts() {
        List<APISQX_Part__c> partsToUpdate = new List<APISQX_Part__c>();

        // Query for active parts without a product reference
        List<APISQX_Part__c> partsWithoutProduct = [SELECT Id, Name, Part_Number__c FROM APISQX_Part__c WHERE Active__c = true AND Product__c = null];

        for(APISQX_Part__c part : partsWithoutProduct) {
            // Check if there's a corresponding product
            Product2 existingProduct = [SELECT Id FROM Product2 WHERE Name = :part.Name AND ProductCode = :part.Part_Number__c LIMIT 1];

            if(existingProduct != null) {
                // Update part with existing product reference
                part.Product__c = existingProduct.Id;
                partsToUpdate.add(part);
            } else {
                // Create new product and update part with its reference
                Product2 newProduct = new Product2(
                    Name = part.Name,
                    ProductCode = part.Part_Number__c,
                    IsActive = true
                );
                insert newProduct;
                part.Product__c = newProduct.Id;
                partsToUpdate.add(part);
            }
        }

        // Update parts
        if(!partsToUpdate.isEmpty()) {
            update partsToUpdate;
        }
    }
}
