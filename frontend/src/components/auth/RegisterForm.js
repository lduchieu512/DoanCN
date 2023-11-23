import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import { useState, useContext } from "react";
import { AuthContext } from "../../contexts/AuthContext";
import { useNavigate } from "react-router-dom";
import AlertMessage from "../layout/AlertMessage";

const RegisterForm = () => {
  let Navigate = useNavigate();

  // Context
  const { regisUser } = useContext(AuthContext);

  const [regisForm, setRegisForm] = useState({
    username: "",
    password: "",
  });

  const [alert, setAlert] = useState(null);

  const { username, password } = regisForm;
  console.log("register");
  const onChangeLoginForm = (event) =>
    setRegisForm({ ...regisForm, [event.target.name]: event.target.value });
  const regis = async (event) => {
    event.preventDefault();

    try {
      const RegisData = await regisUser(regisForm);
      if (RegisData.success) {
        Navigate("/ProductManage");
      } else {
        setAlert({ type: "danger", message: RegisData.message });
        setTimeout(() => setAlert(null), 5000);
      }
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <>
      <Form className="my-4" onSubmit={regis}>
        <AlertMessage info={alert} />
        <Form.Group className="bot">
          <Form.Control
            type="text"
            placeholder="Username"
            name="username"
            required
            value={username}
            onChange={onChangeLoginForm}
          />
        </Form.Group>
        <Form.Group className="bot">
          <Form.Control
            type="password"
            placeholder="Password"
            name="password"
            required
            value={password}
            onChange={onChangeLoginForm}
          />
        </Form.Group>
        <Button variant="success" type="submit">
          Register
        </Button>
      </Form>
    </>
  );
};

export default RegisterForm;
