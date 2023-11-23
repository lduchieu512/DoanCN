import { createContext, useReducer, useEffect, useState } from "react";
import { productReducer } from "../reducers/productReducer";
import {
  PRODUCT_REDUCER_PRODUCT,
  apiUrl,
  ADD_PRODUCT,
  DELETE_PRODUCT,
  UPDATE_PRODUCT,
  FIND_PRODUCT,
  FILTER_PRODUCT,
} from "./constant";
import axios from "axios";

export const ProductContext = createContext();
const ProductContextProvider = ({ children }) => {
  const [productState, dispatch] = useReducer(productReducer, {
    productSelect: null,
    productLoading: true,
    product: [],
  });

  const loadProduct = async () => {
    try {
      let response = await axios.get(`${apiUrl}/products/private`);
      dispatch({
        type: PRODUCT_REDUCER_PRODUCT,
        payload: response.data.Products,
      });
    } catch (error) {
      console.log(error);
      dispatch({
        type: PRODUCT_REDUCER_PRODUCT,
        payload: { productLoading: true, product: [] },
      });
    }
  };

  const getProducts = async () => {
    try {
      const response = await axios.get(`${apiUrl}/products/private`);
      if (response.data.success) {
        dispatch({
          type: PRODUCT_REDUCER_PRODUCT,
          payload: response.data.Products,
        });
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server Error" };
    }
  };

  const filterProducts = async (query) => {
    const response = await axios.post(`${apiUrl}/products/filter/${query}`);
    if (response.data.success) {
      console.log(response.data.Products);
      dispatch({
        type: FILTER_PRODUCT,
        payload: response.data.Products,
      });
    }
  };

  // Find product when user updating product
  const findProducts = (productId) => {
    const product = productState.product.find(
      (productt) => productt._id === productId
    );
    dispatch({
      type: FIND_PRODUCT,
      payload: product,
    });
  };

  const deleteProducts = async (ProductId) => {
    try {
      const response = await axios.delete(`${apiUrl}/products/${ProductId}`);
      if (response.data.success) {
        dispatch({
          type: DELETE_PRODUCT,
          payload: ProductId,
        });
      }
    } catch (error) {
      console.log(error);
    }
  };

  const updateProducts = async (updateProduct) => {
    try {
      const formData = new FormData();
      formData.append("title", updateProduct.title);
      formData.append("description", updateProduct.description);
      formData.append("price", updateProduct.price);
      formData.append("image", updateProduct.image);
      const response = await axios.put(
        `${apiUrl}/products/${updateProduct._id}`,
        formData
      );
      if (response.data.success) {
        dispatch({
          type: UPDATE_PRODUCT,
          payload: response.data.Products,
        });
        console.log(response.data);
        return response.data;
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server Error" };
    }
  };

  const updateOutProducts = async (updateProduct) => {
    console.log("IN2");
    try {
      const { title, description, price } = updateProduct;
      const updateOutProduct = {
        title,
        description,
        price,
      };
      const response = await axios.put(
        `${apiUrl}/products/out/${updateProduct._id}`,
        updateOutProduct
      );
      console.log(response.data.Products);
      if (response.data.success) {
        dispatch({
          type: UPDATE_PRODUCT,
          payload: response.data.Products,
        });
        return response.data;
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server Error" };
    }
  };

  const addProducts = async (newProduct) => {
    try {
      const formData = new FormData();
      formData.append("title", newProduct.title);
      formData.append("description", newProduct.description);
      formData.append("categories", newProduct.categories);
      formData.append("price", newProduct.price);
      formData.append("image", newProduct.image);
      const response = await axios.post(`${apiUrl}/products`, formData);
      console.log(response);
      if (response.data.success) {
        dispatch({
          type: ADD_PRODUCT,
          payload: response.data.product,
        });
        return response.data;
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server Error" };
    }
  };

  const [showAddProductModal, setShowAddProductModal] = useState(false);
  const [showUpdateProductModal, setShowUpdateProductModal] = useState(false);
  const [showToast, setShowToast] = useState({
    show: false,
    message: "",
    type: null,
  });

  useEffect(() => loadProduct(), [productState.productLoading]);

  const productContextData = {
    productState,
    showAddProductModal,
    setShowAddProductModal,
    showUpdateProductModal,
    setShowUpdateProductModal,
    addProducts,
    getProducts,
    showToast,
    setShowToast,
    deleteProducts,
    findProducts,
    updateProducts,
    updateOutProducts,
    filterProducts,
  };

  //return provider
  return (
    <ProductContext.Provider value={productContextData}>
      {children}
    </ProductContext.Provider>
  );
};

export default ProductContextProvider;
