import { LightningElement } from 'lwc';
import createOrder from '@salesforce/apex/RazorPayService.createOrder';

export default class RazorpayForm extends LightningElement {
    amount = 1;

    handleAmountChange(event) {
        this.amount = event.target.value;
    }

    async handlePay() {
        try {
            const payment = {
                Amount__c: parseFloat(this.amount),
                Name : 'Razorpay Payment'
            };

            const checkoutUrl = await createOrder({ payment });
            console.log('Opening Razorpay VF URL:', checkoutUrl);

            window.open(checkoutUrl, '_blank');
        } catch (error) {
            console.error('Error creating order:', error);
            alert('Failed to initiate payment.');
        }
    }
}
