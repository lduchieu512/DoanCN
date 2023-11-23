import React, { useState } from "react";
import { Form, Button } from "react-bootstrap";
import axios from "axios";
import { motion } from "framer-motion";

import { apiUrl } from "../contexts/constant";

const containerVariant = {
  hidden: {
    x: "100vw",
  },
  visible: {
    x: 0,
    transition: {
      ease: "easeInOut",
      duration: 0.25,
    },
  },
  exit: {
    x: "-100vw",
    transition: {
      duration: 0.5,
    },
  },
};

const Setting = () => {
  const [form, setForm] = useState({
    oldPassword: "",
    newPassword: "",
    confirmPassword: "",
  });
  const onSubmit = async (event) => {
    event.preventDefault();
    if (form.oldPassword === form.newPassword) {
      alert("Same Password");
      return;
    }
    if (form.newPassword !== form.confirmPassword) {
      alert("Incorrect Confirm Password");
      return;
    }
    const response = await axios.post(`${apiUrl}/auth/change`, form);
    console.log(response);
    if (response.data.success) {
      setForm({
        oldPassword: "",
        newPassword: "",
        confirmPassword: "",
      });
      alert(response.data.message);
      console.log(form);
    } else {
      alert(response.data.message);
    }
  };
  const onFormChange = (event) => {
    setForm({
      ...form,
      [event.target.name]: event.target.value,
    });
  };
  return (
    <motion.div
      className="Center"
      variants={containerVariant}
      initial="hidden"
      animate="visible"
      exit="exit"
    >
      <Form
        className="px400 Center-horizontal Scroll-vertical"
        onSubmit={onSubmit}
      >
        <Form.Group>
          <Form.Label>Old Password</Form.Label>
          <Form.Control
            placeholder="Enter Old Password"
            type="password"
            name="oldPassword"
            value={form.oldPassword}
            required
            onChange={onFormChange}
          />
        </Form.Group>
        <Form.Group>
          <Form.Label>New Password</Form.Label>
          <Form.Control
            placeholder="Enter New Password"
            type="password"
            name="newPassword"
            value={form.newPassword}
            required
            onChange={onFormChange}
          />
        </Form.Group>
        <Form.Group>
          <Form.Label>Confirm Password</Form.Label>
          <Form.Control
            placeholder="Enter Confirm Password"
            type="password"
            name="confirmPassword"
            value={form.confirmPassword}
            required
            onChange={onFormChange}
          />
        </Form.Group>
        <Button variant="success" type="submit">
          Change
        </Button>
      </Form>
    </motion.div>
  );
};

export default Setting;
