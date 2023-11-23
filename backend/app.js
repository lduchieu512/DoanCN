const express = require("express");
const app = express();
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");
const paypal = require("paypal-rest-sdk");
require("dotenv/config");

//Paypal config
paypal.configure({
  mode: "sandbox", //sandbox or live
  client_id: process.env.PAYPAL_CLIENT_ID,
  client_secret: process.env.PAYPAL_CLIENT_SECRET,
});

//Import routes
const authRouter = require("./routes/auth");
const customerRouter = require("./routes/customer");
const productsRouter = require("./routes/products");
const billsRouter = require("./routes/bill");
const ratingsRouter = require("./routes/rating");
const paymentRouter = require("./routes/payment");
const categoryRouter = require("./routes/category");
//Middleware using
app.use(
  bodyParser.urlencoded({
    // to support URL-encoded bodies
    extended: true,
  })
);
app.use(bodyParser.json());
app.use(cors());
app.use("/uploads", express.static("uploads"));

app.use("/api/auth", authRouter);
app.use("/api/customer", customerRouter);
app.use("/api/products", productsRouter);
app.use("/api/bill", billsRouter);
app.use("/api/ratings", ratingsRouter);
app.use("/api/payment", paymentRouter);
app.use("/api/category", categoryRouter);
//routes

mongoose.connect(process.env.DB_CONNECTION, () => {
  console.log("connect To Database Success");
});

console.log("Server started on port 5000");

app.listen(5000);
