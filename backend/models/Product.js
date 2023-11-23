const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const ProductSchema = mongoose.Schema(
  {
    _id: {
      type: Number,
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    categories: [
      {
        type: String,
        _id: false,
      },
    ],
    image: {
      type: String,
      // required: true,
    },
    date: {
      type: Date,
      default: Date.now,
    },
    user: {
      type: Schema.Types.ObjectId,
      ref: "users",
    },
  },
  { _id: false }
);

module.exports = mongoose.model("Products", ProductSchema);
