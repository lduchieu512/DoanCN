import { Outlet } from "react-router-dom";
import { useNavigate } from "react-router";
import { useContext } from "react";
import { AuthContext } from "../../contexts/AuthContext";
import Spinner from "react-bootstrap/Spinner";

const ProtectedRoute = ({ element: Element, ...rest }) => {
  let Navigate = useNavigate();

  const {
    authState: { authLoading, isAuthenticated },
  } = useContext(AuthContext);
  if (authLoading)
    return (
      <div className="spinner-container">
        {console.log("authloading is in")}
        <Spinner animation="border" variant="info" />
      </div>
    );
  else if (!isAuthenticated) {
    console.log("done authLoading");
    Navigate("/login");
  }

  return isAuthenticated ? <Outlet /> : Navigate("/login");
};

export default ProtectedRoute;
