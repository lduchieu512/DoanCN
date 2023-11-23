const express = require("express");
const router = express.Router();

const categoryEntity = require("../models/Category")

router.get("/", async (req, res) => {
    try {
        let categoryList = await categoryEntity.find();
        res.json({
            success: true,
            categoryList: categoryList
        })
    } catch (error) {
        console.log(error);
        res.status(500).json({
            success: false,
        })
    }
})


module.exports = router;