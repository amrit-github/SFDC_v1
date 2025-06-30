public with sharing class RazorPayService {
    public class RazorpayOrderResponse {
        public String id;
        public String status;
    }

    @AuraEnabled
    public static String createOrder(Payment__c payment) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Razorpay/v1/orders');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'amount' => (Integer)(payment.Amount__c * 100), // in paise
            'currency' => 'INR',
            'receipt' => payment.Name,
            'payment_capture' => true
        };

        req.setBody(JSON.serialize(payload));
        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            RazorpayOrderResponse order = (RazorpayOrderResponse)JSON.deserialize(res.getBody(), RazorpayOrderResponse.class);
            payment.Razorpay_ID__c = order.id;
            payment.Status__c = 'Pending';
            upsert payment;

            // Redirect URL (Razorpay Checkout Hosted Page)
            String vfPageUrl = URL.getOrgDomainUrl().toExternalForm() + '/apex/RazorpayCheckoutPage'
                         + '?orderId=' + order.id
                         + '&amount=' + String.valueOf((Integer)(payment.Amount__c));

        return vfPageUrl;
        } else {
            throw new AuraHandledException('Failed to create Razorpay order');
        }
    }
}