@RestResource(urlMapping='/razorpay/webhook')
global without sharing class RazorpayWebhook {
    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        // Safely parse to Map
        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(body);

        // Extract nested fields step-by-step
        String event = (String) payloadMap.get('event');

        if (event == 'payment.captured') {
            Map<String, Object> payload = (Map<String, Object>) payloadMap.get('payload');
            Map<String, Object> paymentWrapper = (Map<String, Object>) payload.get('payment');
            Map<String, Object> paymentEntity = (Map<String, Object>) paymentWrapper.get('entity');

            // Extract fields safely from paymentEntity
            String razorpayOrderId = (String) paymentEntity.get('order_id');
            String razorpayPaymentId = (String) paymentEntity.get('id');
            String status = (String) paymentEntity.get('status');

            // Update existing Payment__c record based on Razorpay_ID__c
            List<Payment__c> payments = [
                SELECT Id, Status__c 
                FROM Payment__c 
                WHERE Razorpay_ID__c = :razorpayOrderId 
                WITH SYSTEM_MODE
                LIMIT 1
            ];

            if (!payments.isEmpty()) {
                Payment__c p = payments[0];
                p.Status__c = 'Paid';
                update p;
            }
        }

        // Optionally return 200 OK response (not mandatory in Apex REST)
    }
}
