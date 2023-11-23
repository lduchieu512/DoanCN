import { createContext, useReducer } from "react";
import { postReducer } from "../reducers/postReducer";
import { apiUrl } from "./constant";
import axios from "axios";

export const PostContext = createContext();

const PostContextProvider = ({ children }) => {
  // State (manage post)
  // dispatch (communicate to reducer)
  const [postState, dispatch] = useReducer(postReducer, {
    posts: [],
    postsLoading: true,
  });

  // Get all posts
  const getPosts = async () => {
    try {
      const response = await axios.get(`${apiUrl}/posts`);
      if (response.data.success) {
        dispatch({
          type: "POSTS_LOADED_SUCCESS",
          payload: response.data.posts,
        });
      }
    } catch (error) {
      return error.response.data
        ? error.response.data
        : { success: false, message: "Server error" };
    }
  };

  //Post context data
  const postContextData = { postState, getPosts };

  return (
    <PostContextProvider value={postContextData}>
      {children}
    </PostContextProvider>
  );
};

export default PostContextProvider;
