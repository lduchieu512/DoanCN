import { createContext, useReducer, useEffect } from "react";
import { apiUrl, VIEW_REDUCER_BILLS } from "./constant";
import axios from "axios";
import { viewReducer } from "../reducers/viewReducer";

export const ViewContext = createContext();
const ViewContextProvider = ({ children }) => {
  const [viewState, dispatch] = useReducer(viewReducer, {
    yearLoading: true,
    yearproduct: [],
    yearUsers: [],
  });
  const getBills = async () => {
    try {
      let response = await axios.get(`${apiUrl}/bill/yearchart`);
      if (response.data.success) {
        dispatch({
          type: VIEW_REDUCER_BILLS,
          payload: response.data,
        });
        return response.data;
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server Error" };
    }
  };

  useEffect(() => getBills(), [viewState.yearLoading]);
  const viewContextData = {
    viewState,
    getBills,
  };

  return (
    <ViewContext.Provider value={viewContextData}>
      {children}
    </ViewContext.Provider>
  );
};

export default ViewContextProvider;
