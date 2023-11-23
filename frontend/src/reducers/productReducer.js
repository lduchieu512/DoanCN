import {
  PRODUCT_REDUCER_PRODUCT,
  ADD_PRODUCT,
  PRODUCT_REDUCER_FAIL,
  DELETE_PRODUCT,
  UPDATE_PRODUCT,
  FIND_PRODUCT,
  FILTER_PRODUCT,
} from "../contexts/constant";

export const productReducer = (state, action) => {
  const { type, payload } = action;

  switch (type) {
    case PRODUCT_REDUCER_PRODUCT:
      return { ...state, product: payload, productLoading: false };
    case PRODUCT_REDUCER_FAIL:
      return { ...state, product: [], productLoading: false };
    case ADD_PRODUCT:
      return { ...state, product: [...state.product, payload] };
    case DELETE_PRODUCT:
      return {
        ...state,
        product: state.product.filter((product) => product._id !== payload),
      };
    case FIND_PRODUCT:
      return { ...state, productSelect: payload };
    case FILTER_PRODUCT:
      return { ...state, product: payload };
    case UPDATE_PRODUCT:
      const newProducts = state.product.map((producthold) =>
        producthold._id === payload._id ? payload : producthold
      );
      return { ...state, product: newProducts };
    default:
      return state;
  }
};
