import { apiUrl } from "../contexts/constant";
import axios from "axios";

const fetchData = async () => {
  try {
    const response = await axios.get(`${apiUrl}/posts`);
    if (response.data.success) {
      console.log(response.data.posts);
      return response.data.posts;
    }
  } catch (error) {
    return error.response.data
      ? error.response.data
      : { success: false, message: "Server error" };
  }
};

export default fetchData;
