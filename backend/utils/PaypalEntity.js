class PaypalEntity {
  #create_payment_json;
  constructor(itemList, total_price) {
    this.create_payment_json = {
      intent: "sale",
      payer: {
        payment_method: "paypal",
      },
      redirect_urls: {
        return_url: "https://www.google.com/",
        cancel_url: "https://www.google.com/",
      },
      transactions: [
        {
          item_list: {
            items: itemList,
          },
          amount: {
            currency: "USD",
            total: total_price,
          },
          description: "This is the payment description.",
        },
      ],
    };
  }
  createPayment() {
    return this.#create_payment_json;
  }
}
