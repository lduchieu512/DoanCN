import React, { useEffect } from "react";
import { useNavigate } from "react-router";
import { Form } from "react-bootstrap";
const Landing = () => {
  let navigate = useNavigate();
  useEffect(() => {
    navigate("/login");
  }, [navigate]);
  const onChangeProduct = (event) => {
    console.log(event.target.files[0]);
  };
  return (
    <Form>
      <Form.Label>Image</Form.Label>
      <Form.Control type="file" name="image" onChange={onChangeProduct} />
    </Form>
  );
};

export default Landing;
