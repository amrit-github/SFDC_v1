public with sharing class RazorpayPageController {
    public String razorpayKey { get; private set; }

    public RazorpayPageController() {
        razorpayKey = 'rzp_test_'; // 🔒 Replace with your test key
    }
}
