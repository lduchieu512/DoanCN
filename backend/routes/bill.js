const express = require("express");
const router = express.Router();
const argon2 = require("argon2");
const jwt = require("jsonwebtoken");
const datefns = require("date-fns");
const verifyToken = require("../middleware/auth");
const paypal = require("paypal-rest-sdk");
require("dotenv").config();

const Bill = require("../models/Bill");
const Customer = require("../models/Customer");

// @route Get api/bill/all
// @desc Retrieve all bills
// @access Private
router.get("/all", verifyToken, async (req, res) => {
  try {
    let Bills = await Bill.aggregate([
      {
        $unwind: "$products",
      },
      {
        $lookup: {
          from: "products",
          localField: "products.product",
          foreignField: "_id",
          as: "products.product",
        },
      },
      {
        $group: {
          _id: "$_id",
          products: {
            $push: "$products",
          },
          total: { $first: "$total" },
          status: { $first: "$status" },
          customer: { $first: "$customer" },
          date: { $first: "$date" },
        },
      },
      {
        $lookup: {
          from: "customers",
          localField: "customer",
          foreignField: "_id",
          as: "customerEntity",
        },
      },
    ]);

    Bills.map((bill) => {
      let str = new Date(bill.date);
      let time = str.toString().split("GMT");
      bill.date = time[0];
    });
    res.json({
      success: true,
      Bills,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route Get api/bill/date
// @desc Retrieve all bills in that date
// @access Private
router.post("/date", verifyToken, async (req, res) => {
  const { date } = req.body;
  let query = new Date(date);
  try {
    if (date.length !== 0) {
      let Bills = await Bill.aggregate([
        {
          $match: {
            date: {
              $gte: datefns.startOfDay(query),
              $lte: datefns.endOfDay(query),
            },
          },
        },
        {
          $unwind: "$products",
        },
        {
          $lookup: {
            from: "products",
            localField: "products.product",
            foreignField: "_id",
            as: "products.product",
          },
        },
        {
          $group: {
            _id: "$_id",
            products: {
              $push: "$products",
            },
            total: { $first: "$total" },
            status: { $first: "$status" },
            customer: { $first: "$customer" },
            date: { $first: "$date" },
          },
        },
        {
          $lookup: {
            from: "customers",
            localField: "customer",
            foreignField: "_id",
            as: "customerEntity",
          },
        },
      ]);

      Bills.map((bill) => {
        let str = new Date(bill.date);
        let time = str.toString().split("GMT");
        bill.date = time[0];
      });
      res.json({ success: true, Bills });
    } else {
      let Bills = await Bill.aggregate([
        {
          $unwind: "$products",
        },
        {
          $lookup: {
            from: "products",
            localField: "products.product",
            foreignField: "_id",
            as: "products.product",
          },
        },
        {
          $group: {
            _id: "$_id",
            products: {
              $push: "$products",
            },
            total: { $first: "$total" },
            status: { $first: "$status" },
            customer: { $first: "$customer" },
            date: { $first: "$date" },
          },
        },
        {
          $lookup: {
            from: "customers",
            localField: "customer",
            foreignField: "_id",
            as: "customerEntity",
          },
        },
      ]);

      Bills.map((bill) => {
        let str = new Date(bill.date);
        let time = str.toString().split("GMT");
        bill.date = time[0];
      });
      res.json({ success: true, Bills });
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

router.put("/:id", verifyToken, async (req, res) => {
  const { status } = req.body;
  try {
    const updateBillCondition = { _id: req.params.id };

    updatedBill = await Bill.findOneAndUpdate(
      updateBillCondition,
      { status: status },
      { new: true }
    );

    if (!updatedBill)
      return res.status(401).json({
        success: false,
        message: "Bill not found or user is not authorized",
      });

    const response = await Bill.aggregate([
      {
        $match: {
          _id: updatedBill._id,
        },
      },
      {
        $unwind: "$products",
      },
      {
        $lookup: {
          from: "products",
          localField: "products.product",
          foreignField: "_id",
          as: "products.product",
        },
      },
      {
        $group: {
          _id: "$_id",
          products: {
            $push: "$products",
          },
          total: { $first: "$total" },
          status: { $first: "$status" },
          customer: { $first: "$customer" },
          date: { $first: "$date" },
        },
      },
      {
        $lookup: {
          from: "customers",
          localField: "customer",
          foreignField: "_id",
          as: "customerEntity",
        },
      },
    ]);

    res.json({
      success: true,
      message: "Bill is Updated",
      Bills: response,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/get
// @desc Retrieve all bill of Customer
// @access Private
router.post("/get", async (req, res) => {
  const { customerId } = req.body;
  if (!customerId)
    return res
      .status(400)
      .json({ success: false, message: "Missing CustomerId" });
  try {
    // let Bills = await Bill.find({ customer: customerId })
    //   .populate("customer", ["username"])
    //   .populate("products.product")
    //   .select("-__v");
    let Bills = await Bill.aggregate([
      {
        $match: {
          customer: parseInt(customerId),
        },
      },
      {
        $unwind: "$products",
      },
      {
        $lookup: {
          from: "products",
          localField: "products.product",
          foreignField: "_id",
          as: "products.product",
        },
      },
      {
        $group: {
          _id: "$_id",
          products: {
            $push: "$products",
          },
          total: { $first: "$total" },
          status: { $first: "$status" },
          customer: { $first: "$customer" },
          date: { $first: "$date" },
        },
      },
      {
        $lookup: {
          from: "customers",
          localField: "customer",
          foreignField: "_id",
          as: "customerEntity",
        },
      },
    ]);

    Bills.map((bill) => {
      let str = new Date(bill.date);
      let time = str.toString().split("GMT");
      bill.date = time[0];
    });

    res.json({
      success: true,
      Bills,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/bill
// @desc create bill for customer
// @access Private
router.post("/", async (req, res) => {
  const { products, total, customerId } = req.body;
  let array = [];
  //Validation
  if (!products)
    return res
      .status(400)
      .json({ success: false, message: "Missing Products" });
  if (!customerId)
    return res
      .status(400)
      .json({ success: false, message: "Missing CustomerId" });
  for (x in products) {
    let hold = {
      product: products[x].productId,
      quantity: products[x].quantity,
      price: products[x].price,
    };

    array.push(hold);
  }

  try {
    const newBill = new Bill({
      products: array,
      total: total,
      customer: customerId,
      status: "Waiting",
    });
    await newBill.save();
    res.json({
      success: true,
      message: "Order Successfully",
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route GET api/bill/yearchart
// @desc get Bills Chart
// @access Private
router.get("/yearchart", verifyToken, async (req, res) => {
  const monthEnum = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December",
  };
  try {
    const array = [];
    today = new Date();
    for (let i = 0; i <= 11; i++) {
      let Bills = await Bill.find({
        date: {
          $gte: new Date(today.getFullYear(), i, 1), // 00:00 am 2023/01/01
          $lte: new Date(today.getFullYear(), i + 1, 0), // 11:59 pm 2023/01/31
        },
      });
      let MonthName = monthEnum[i + 1];

      miniArray = [MonthName, Bills];
      array.push(miniArray);
    }

    let users = await Customer.find({});

    res.json({ success: true, array, users: users });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

module.exports = router;
