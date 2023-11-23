const express = require("express");
const router = express.Router();
const verifyCustomerToken = require("../middleware/customerAuth");
const Product = require("../models/Product");
const Rating = require("../models/Rating");

const {
  findNearestNeighbors,
  getObjectLength,
  getObjectName,
  predictRatings,
} = require("../utils/findNearestNeighbors");

// @route GET api/ratings/one
// @desc Rate the product
// @access Private
router.get("/one", verifyCustomerToken, async (req, res, next) => {
  const customerId = req.customerId;
  try {
    const Ratings = await Rating.find({ customerId });
    return res.json({ success: true, Ratings });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route GET api/ratings/all
// @desc get product by KNN
// @access Private
router.get("/all", verifyCustomerToken, async (req, res, next) => {
  let arr = [];
  let tempo = [];
  try {
    const Ratings = await Rating.find();
    const products = await Product.find({});
    for (let i = 0; i < Ratings.length; i++) {
      let { customerId, productId, ratingScore } = Ratings[i];
      let cusToString = customerId.toString();
      let prodToString = productId.toString();
      let mv = {};
      mv[prodToString] = ratingScore;
      const assign = Object.assign(tempo[cusToString] || {}, mv);
      tempo[cusToString] = assign;
    }

    const names = getObjectName(tempo);
    for (let x of names) {
      tempo[x].name = x;
      arr.push(tempo[x]);
    }
    let user = await predictRatings(arr, products, req.customerId);
    const prodIds = await Rating.find({ customerId: user });
    let stringIds = [];
    for (let x of prodIds) {
      if (x.ratingScore >= 3) {
        stringIds.push({ _id: x.productId, score: x.ratingScore });
      }
    }
    stringIds.sort((a, b) => {
      return b.score - a.score;
    });
    stringIds = stringIds.slice(0, 5);
    const finalArr = [];
    for (let x of stringIds) {
      finalArr.push(x._id);
    }
    const result = await Product.find({ _id: { $in: finalArr } });
    res.json({ success: true, Products: result });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/ratings/
// @desc Rate the product
// @access Private
router.post("/", verifyCustomerToken, async (req, res, next) => {
  const customerId = req.customerId;
  const { product_id, score } = req.body;
  try {
    if (!customerId)
      return res.json({ success: false, message: "customerId is missing" });
    if (!product_id)
      return res.json({ success: false, message: "productId is missing" });
    if (!score)
      return res.json({ success: false, message: "ratingScore is missing" });
    console.log("in");
    const Ratings = await Rating.find({
      product_id: product_id,
      user_id: customerId,
    });
    if (Ratings.length !== 0) {
      return res.json({ success: false, message: "product was already rated" });
    }

    const newRating = new Rating({
      user_id: customerId,
      product_id: product_id,
      score: score,
    });
    await newRating.save();
    return res.json({
      success: true,
      message: "Add a new Rating Successfully",
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

module.exports = router;
