const express = require("express");
const router = express.Router();
const paypal = require("paypal-rest-sdk");

paypal.configure({
  mode: "sandbox", //sandbox or live
  client_id: process.env.PAYPAL_CLIENT_ID,
  client_secret: process.env.PAYPAL_CLIENT_SECRET,
});

router.post("/", (req, res) => {
  const { products, total } = req.body;
  let itemList = [];
  for (let item of products) {
    console.log(item);
    itemList.push({
      name: item.title,
      sku: "item",
      price: item.price,
      currency: "USD",
      quantity: item.quantity,
    });
  }

  let create_payment_json = {
    intent: "sale",
    payer: {
      payment_method: "paypal",
    },
    redirect_urls: {
      return_url: "http://localhost:5000/api/payment/success",
      cancel_url: "http://localhost:5000/api/payment/failed",
    },
    transactions: [
      {
        item_list: {
          items: itemList,
        },
        amount: {
          currency: "USD",
          total: total,
        },
        description: "This is the payment description.",
      },
    ],
  };

  paypal.payment.create(create_payment_json, (error, payment) => {
    if (error) {
      throw error;
    } else {
      for (let i = 0; i < payment.links.length; i++) {
        if (payment.links[i].rel === "approval_url") {
          res.redirect(payment.links[i].href);
        }
      }
    }
  });
});

router.get("/success", (req, res) => {
  const payerID = req.query.PayerID;
  const paymentID = req.query.paymentID;

  const execute_payment_json = {
    payer_id: payerID,
    transactions: [
      {
        amount: {
          currency: "USD",
          total: "5.00",
        },
      },
    ],
  };

  paypal.payment.execute(paymentID, execute_payment_json, (error, payment) => {
    if (error) {
      console.log(error.response);
      throw error;
    } else {
      console.log(JSON.stringify(payment));
      res.send("success");
    }
  });
});

module.exports = router;
