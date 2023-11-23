const express = require("express");
const router = express.Router();
const verifyToken = require("../middleware/auth");
const verifyCustomerToken = require("../middleware/customerAuth");
const Product = require("../models/Product");
const Rating = require("../models/Rating");
const fs = require("fs");
const multer = require("multer");
const axios = require("axios");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./uploads/");
  },
  filename: function (req, file, cb) {
    let date = new Date().toISOString();
    let str = date;
    while (str.match(":") !== null) {
      str = str.replace(":", "_");
    }

    cb(null, str + file.originalname);
  },
});

const fileFilter = (req, file, cb) => {
  //reject a file
  if (
    file.mimetype === "image/jpeg" ||
    file.mimetype === "image/png" ||
    file.mimetype === "image/jpg"
  )
    cb(null, true);
  else cb(null, false);
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 5,
  },
  fileFilter: fileFilter,
});

// @route POST api/products
// @desc Create product
// @access Private
router.post(
  "/",
  verifyToken,
  upload.single("image"),
  async (req, res, next) => {
    const { title, description, price, categories } = req.body;
    let fixCategory = categories.split(",");
    console.log(fixCategory);
    const image = req.file.path;
    // Validation
    if (!title)
      return res
        .status(400)
        .json({ success: false, message: "Title is required" });
    if (!description)
      return res
        .status(400)
        .json({ success: false, message: "Description is required" });
    if (!price)
      return res
        .status(400)
        .json({ success: false, message: "Price is required" });
    // if (!image)
    //   return res
    //     .status(400)
    //     .json({ success: false, message: "Image is required" });

    try {
      const lastestProduct = await Product.findOne({}).sort({ _id: "desc" });
      let _id;
      if (lastestProduct === null) {
        _id = 1;
      } else {
        _id = lastestProduct._id + 1;
      }
      const newProduct = new Product({
        _id,
        title,
        description,
        price,
        categories: fixCategory,
        image,
        user: req.userId,
      });
      await newProduct.save();
      res.json({
        success: true,
        message: "Add a new product successfully",
        product: newProduct,
      });
    } catch (error) {
      console.log(error);
      res
        .status(500)
        .json({ success: false, message: "Interval server error" });
    }
  }
);

router.get("/recommend/:q", async (req, res) => {
  const textSearch = req.params.q;
  const userId = parseInt(textSearch) - 1;

  try {
    const userHasRating = await Rating.find({ user_id: textSearch });
    if (
      userHasRating == null ||
      userHasRating == undefined ||
      userHasRating.length == 0
    ) {
      const recommend = await axios.get(
        `http://localhost:5500/nonrating?q=${userId}`
      );

      const response = await Product.find({
        _id: { $in: recommend.data.response },
      });

      if (response.length !== 0) {
        console.log(response);
        res.json({ success: true, Products: response });
      } else {
        res.status(500).json({ success: false, Products: [] });
      }
    } else {
      const recommend = await axios.get(`http://localhost:5500/?q=${userId}`);

      const response = await Product.find({
        _id: { $in: recommend.data.response },
      });

      if (response.length !== 0) {
        console.log(response);
        res.json({ success: true, Products: response });
      } else {
        res.status(500).json({ success: false, Products: [] });
      }
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false });
  }
});

// @route GET api/products
// @desc GET product
// @access Private
router.get("/", async (req, res) => {
  try {
    const Products = await Product.find({});

    res.json({ success: true, Products });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route GET api/products/not-rating
// @desc GET all products havent rating
// @access Private
router.get("/not-rating", verifyCustomerToken, async (req, res, next) => {
  try {
    const Ratings = await Rating.find({ user_id: req.customerId }).select(
      "product_id"
    );
    const array = [];
    for (let x of Ratings) {
      array.push(x.product_id.toString());
    }
    const Products = await Product.find({}).select("-__v");
    const productNotRating = Products.filter((product) => {
      return !array.includes(product._id.toString());
    });
    res.json({ success: true, Products: productNotRating });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/products/customer
// @desc POST product
// @access public
router.post("/customer", async (req, res) => {
  try {
    const Products = await Product.find({ user: req.body.userId }).populate(
      "user",
      ["username"]
    );

    res.json({ success: true, Products });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route GET api/products/detail
// @desc GET product
// @access Private
router.get("/detail/:q", async (req, res) => {
  let queryContent = req.params.q;
  console.log("detail:", queryContent);
  try {
    const Products = await Product.find({ categories: queryContent });
    console.log(Products);
    res.json({ success: true, Products });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

router.get("/private", verifyToken, async (req, res) => {
  try {
    const Products = await Product.find({ user: req.userId }).populate("user", [
      "username",
    ]);
    res.json({ success: true, Products });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route POST api/products/filter/:query
// @descs filted product
// @access Private
router.post("/filter/:query", verifyToken, async (req, res) => {
  try {
    const productFilterCondition = req.params.query;
    const FilterProducts = await Product.find({
      title: {
        $regex: new RegExp(productFilterCondition.toLowerCase(), "i"),
      },
    });
    res.json({
      success: true,
      Products: FilterProducts,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route DELETE api/products/:id
// @desc DELETE product
// @access Private
router.delete("/:id", verifyToken, async (req, res) => {
  try {
    const productDeleteCondition = { _id: req.params.id, user: req.userId };
    const deletedProduct = await Product.findOneAndDelete(
      productDeleteCondition
    );

    if (!deletedProduct)
      return res.status(401).json({
        success: false,
        message: "Product not found or user not authorized",
      });
    res.json({
      success: true,
      message: "Product Deleted",
      Products: deletedProduct,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route PUT api/products/:id
// @desc Update product
// @access Private
router.put("/:id", verifyToken, upload.single("image"), async (req, res) => {
  const { title, description, price } = req.body;
  const image = req.file.path;
  try {
    let updatedProduct = {
      title,
      description: description || "",
      price,
      image,
    };
    const productUpdateCondition = { _id: req.params.id, user: req.userId };

    updatedProduct = await Product.findOneAndUpdate(
      productUpdateCondition,
      updatedProduct,
      { new: true }
    );
    if (!updatedProduct)
      return res.status(401).json({
        success: false,
        message: "Product not found or user is not authorized",
      });
    res.json({
      success: true,
      message: "Product is Updated",
      Products: updatedProduct,
    });
    console.log("product is update", updatedProduct);
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

// @route PUT api/products/out/:id
// @desc Update product without image
// @access Private
router.put("/out/:id", verifyToken, async (req, res) => {
  const { title, description, price } = req.body;
  try {
    let updatedProduct = {
      title,
      description: description || "",
      price,
    };
    const productUpdateCondition = { _id: req.params.id, user: req.userId };

    updatedProduct = await Product.findOneAndUpdate(
      productUpdateCondition,
      updatedProduct,
      { new: true }
    );
    if (!updatedProduct)
      return res.status(401).json({
        success: false,
        message: "Product not found or user is not authorized",
      });
    res.json({
      success: true,
      message: "Product is Updated",
      Products: updatedProduct,
    });
    console.log("product is updated", updatedProduct);
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Interval server error" });
  }
});

module.exports = router;
