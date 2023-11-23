const express = require("express");
const router = express.Router();
const argon2 = require("argon2");
const jwt = require("jsonwebtoken");
const verifyToken = require("../middleware/auth");
const verifyCustomerToken = require("../middleware/customerAuth");
require("dotenv").config();

const Customer = require("../models/Customer");

// @route POST api/customer/
// @desc Check customer
// @access Private
router.post("/", verifyCustomerToken, async (req, res) => {
  // check data
  if (!req.customerId)
    return res
      .status(400)
      .json({ success: false, message: "Missing CustumerId" });
  try {
    // Check for existing user
    const customer = await Customer.findOne({
      _id: req.customerId,
    }).select("-__v");
    if (!customer)
      return res
        .status(400)
        .json({ success: false, message: "Custumer is not exist" });

    res.json({
      success: true,
      message: "Customer Found",
      customer,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/customer/login
// @desc Check customer
// @access Public
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  // check data
  if (!username || !password)
    return res
      .status(400)
      .json({ success: false, message: "Missing Username and/or Password" });
  try {
    // Check for existing user
    const customer = await Customer.findOne({ username }).select("+password");
    if (!customer)
      return res
        .status(400)
        .json({ success: false, message: "Incorrect username or password" });

    // Username found
    const passwordValid = await argon2.verify(customer.password, password);
    if (!passwordValid)
      return res
        .status(400)
        .json({ success: false, message: "Incorrect username or password" });
    const accessToken = jwt.sign(
      {
        customerId: customer._id,
      },
      process.env.ACCESS_TOKEN_SECRET
    );
    const push = {
      username: customer.username,
      _id: customer._id,
      createdAt: customer.createdAt,
    };
    res.json({
      success: true,
      message: "Customer logged in successfully",
      push,
      accessToken: accessToken,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/customer/register
// @desc create customer
// @access Public
router.post("/register", async (req, res) => {
  // get customer
  const { username, password } = req.body;

  // validation
  if (!username || !password)
    return res
      .status(400)
      .json({ success: false, message: "Missing Username and/or Password" });
  try {
    // Pass all
    const hashedPassword = await argon2.hash(password);
    const lastCustomer = await Customer.findOne({}).sort({ _id: "desc" });
    let _id;
    if (lastCustomer === null) {
      _id = 1;
    } else {
      _id = lastCustomer._id + 1;
    }
    const newCustomer = new Customer({
      _id,
      username,
      password: hashedPassword,
    });
    await newCustomer.save();
    const push = {
      username: newCustomer.username,
      _id: newCustomer._id,
      createdAt: newCustomer.createdAt,
    };
    res.json({
      success: true,
      message: "Customer created successfully",
      push,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

module.exports = router;
