import React from "react";
import Navbar from "react-bootstrap/Navbar";
import Nav from "react-bootstrap/Nav";
import LogoutIcon from "../../assets/logout.svg";
import Button from "react-bootstrap/Button";
import Image from "react-bootstrap/Image";
import { Link } from "react-router-dom";
import { AuthContext } from "../../contexts/AuthContext";
import { useContext } from "react";
import { motion } from "framer-motion";
import Avatar from "../../assets/3551739.jpg";
import { Card } from "react-bootstrap";

const containerVariant = {
  hidden: {
    y: "-100vh",
  },
  visible: {
    y: 0,
    transition: {
      type: "tween",
      duration: 0.5,
    },
  },
};

const NavbarMenu = ({ activate }) => {
  const {
    authState: { user },
    logoutUser,
  } = useContext(AuthContext);

  const logout = () => logoutUser();

  return (
    <Navbar
      variants={containerVariant}
      initial="hidden"
      animate="visible"
      as={motion.Navbar}
      expand="lg"
      bg="secondary"
      variant="dark"
    >
      <Navbar.Toggle aria-controls="basic-navbar-nav" />
      <Navbar.Collapse id="basic-navbar-nav">
        <Nav className="mr-auto">
          {/* <Nav.Link
            className="font-weight-bolder text-write"
            to="/view"
            as={Link}
            active={activate === "view" ? true : false}
          >
            View
          </Nav.Link> */}
          {/* <Nav.Link
            className="font-weight-bolder text-write"
            to="/dashboard"
            as={Link}
            active={activate === "/dashboard" ? true : false}
          >
            DashBoard
          </Nav.Link> */}
          <Nav.Link
            className="font-weight-bolder text-write"
            to="/productmanage"
            as={Link}
            active={activate === "/productmanage" ? true : false}
          >
            Product Manage
          </Nav.Link>
          <Nav.Link
            className="font-weight-bolder text-write"
            to="/bills"
            as={Link}
            active={activate === "/bills" ? true : false}
          >
            Bills
          </Nav.Link>
          <Nav.Link
            className="font-weight-bolder text-write"
            to="/setting"
            as={Link}
            active={activate === "/setting" ? true : false}
          >
            Setting
          </Nav.Link>
        </Nav>
        <Nav>
          <Card>
            <Nav.Link className="font-weight-bolder text-white" disabled>
              <Image roundedCircle src={Avatar} width={50} height={35} />
              <span style={{ color: "black" }}>
                {user && user.username.toUpperCase()}
              </span>
            </Nav.Link>
          </Card>
          <Button
            variant="secondary"
            className="font-weight-bolder text-white"
            onClick={logout}
          >
            <img
              src={LogoutIcon}
              alt="logoutIcon"
              width="32"
              height="32"
              className="mr-2"
            />
          </Button>
        </Nav>
      </Navbar.Collapse>
    </Navbar>
  );
};

export default NavbarMenu;
