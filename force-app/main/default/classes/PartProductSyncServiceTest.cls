@isTest
public class PartProductSyncServiceTest {
    @isTest
    static void testSynchronizePartsAndProducts() {
        // Test case 1: Synchronize parts without corresponding products
        APISQX_Part__c testPartWithoutProduct = new APISQX_Part__c(
            Name = 'Test Part 1',
            Part_Number__c = '12345',
            Active__c = true
        );
        insert testPartWithoutProduct;

        Test.startTest();
        PartProductSyncService.synchronizePartsAndProducts();
        Test.stopTest();

        testPartWithoutProduct = [SELECT Id, Product__c FROM APISQX_Part__c WHERE Id = :testPartWithoutProduct.Id];
        System.assertNotEquals(null, testPartWithoutProduct.Product__c, 'Product reference should not be null');

        // Verify that a new product was created and linked to the part
        Product2 createdProduct = [SELECT Id, Name, ProductCode, IsActive FROM Product2 WHERE Id = :testPartWithoutProduct.Product__c];
        System.assertNotEquals(null, createdProduct, 'New product should have been created');
        System.assertEquals('Test Part 1', createdProduct.Name, 'Product name should match part name');
        System.assertEquals('12345', createdProduct.ProductCode, 'Product code should match part number');
        System.assertEquals(true, createdProduct.IsActive, 'Product should be active');
    }

    @isTest
    static void testSynchronizePartsWithExistingProducts() {
        // Create test data: Part with corresponding existing product
        Product2 existingProduct = new Product2(
            Name = 'Test Product',
            ProductCode = '54321',
            IsActive = true
        );
        insert existingProduct;

        APISQX_Part__c testPartWithProduct = new APISQX_Part__c(
            Name = existingProduct.Name,
            Part_Number__c = existingProduct.ProductCode,
            Active__c = true
        );
        insert testPartWithProduct;

        Test.startTest();
        PartProductSyncService.synchronizePartsAndProducts();
        Test.stopTest();

        // Verify that part was updated with existing product reference
        testPartWithProduct = [SELECT Id, Product__c FROM APISQX_Part__c WHERE Id = :testPartWithProduct.Id];
        System.assertEquals(existingProduct.Id, testPartWithProduct.Product__c, 'Part should have existing product reference');
    }
}
