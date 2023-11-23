import { createContext, useReducer, useEffect } from "react";
import { billReducer } from "../reducers/billReducer";
import { apiUrl, BILL_REDUCER_LOAD_BILL, UPDATE_BILL } from "./constant";
import axios from "axios";

export const BillContext = createContext();
const BillContextProvider = ({ children }) => {
  const [billState, dispatch] = useReducer(billReducer, {
    billLoading: true,
    bill: null,
  });

  const loadBill = async () => {
    try {
      console.log("load Data");
      let response = await axios.get(`${apiUrl}/bill/all`);
      dispatch({
        type: BILL_REDUCER_LOAD_BILL,
        payload: response.data.Bills,
      });
    } catch (error) {
      console.log(error);
      dispatch({
        type: BILL_REDUCER_LOAD_BILL,
        payload: { billLoading: true, bill: null },
      });
    }
  };

  const updateDateBills = async (date) => {
    try {
      const response = await axios.post(`${apiUrl}/bill/date`, date);
      if (response.data.success) {
        dispatch({
          type: BILL_REDUCER_LOAD_BILL,
          payload: response.data.Bills,
        });
        console.log(response.data);
        return response.data;
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : {
            success: false,
            message: "Server Error",
          };
    }
  };

  const updateBills = async (updateBill) => {
    try {
      const response = await axios.put(
        `${apiUrl}/bill/${updateBill._id}`,
        updateBill
      );
      if (response.data.success) {
        console.log(response.data.Bills);
        dispatch({
          type: UPDATE_BILL,
          payload: response.data.Bills[0],
        });
        console.log(response.data);
        return response.data;
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : {
            success: false,
            message: "Server Error",
          };
    }
  };

  const getBills = async () => {
    try {
      let response = await axios.get(`${apiUrl}/bill/all`);
      dispatch({
        type: BILL_REDUCER_LOAD_BILL,
        payload: response.data.Bills,
      });
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server Error" };
    }
  };
  useEffect(() => {
    loadBill();
  }, [billState.billLoading]);

  const billContextData = {
    billState,
    getBills,
    updateBills,
    updateDateBills,
  };

  return (
    <BillContext.Provider value={billContextData}>
      {children}
    </BillContext.Provider>
  );
};

export default BillContextProvider;
