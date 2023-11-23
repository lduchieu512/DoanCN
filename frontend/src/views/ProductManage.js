import AddIcon from "../assets/plus-circle-fill.svg";
import { useContext, useEffect } from "react";
import {
  Spinner,
  OverlayTrigger,
  Tooltip,
  Row,
  Button,
  Card,
  Toast,
  Table,
} from "react-bootstrap";
import { motion } from "framer-motion";

import { AuthContext } from "../contexts/AuthContext";
import { ProductContext } from "../contexts/ProductContext";
import SearchBar from "../components/layout/SearchBar";
import AddProductModel from "../components/products/AddProductModel";
import UpdateProductModel from "../components/products/UpdateProductModel";
import Products from "../components/products/Products";


const ProductManage = () => {
  const {
    authState: { user },
  } = useContext(AuthContext);
  const {
    productState: { productSelect, productLoading, product },
    setShowAddProductModal,
    getProducts,
    showToast: { show, message, type },
    setShowToast,
  } = useContext(ProductContext);
  let body = null;
  useEffect(() => {
    getProducts();
  }, [user, productLoading]);

  getData();
  async function getData() {
    if (productLoading) {
      body = (
        <div className="spinner-container">
          <Spinner animation="border" variant="info" />
        </div>
      );
    } else {
      if (product.length === 0) {
        body = (
          <>
            <Card className="text-center mx-5 my-5">
              <Card.Header as="h1">Hi {user.username}</Card.Header>
              <Card.Body>
                <Card.Title>This is your Store</Card.Title>
                <Card.Text>
                  Click the button below to get your first product
                </Card.Text>
                <Button
                  variant="primary"
                  onClick={setShowAddProductModal.bind(this, true)}
                >
                  Create Product!
                </Button>
              </Card.Body>
            </Card>
          </>
        );
      } else {
        body = (
          <>
            <Table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Image</th>
                  <th>Title</th>
                  <th>Price</th>
                  <th>Category</th>
                  <th>Date Created</th>
                  <th colSpan={2}>Function</th>
                </tr>
              </thead>
              <tbody>
                {product.map((products, idx) => {
                  return (
                    <Products
                      key={products._id}
                      products={products}
                      idx={idx}
                    />
                  );
                })}
              </tbody>
            </Table>
          </>
        );
      }
    }
  }
  return (
    <div style={{marginLeft: '320px'}}>
        <SearchBar />
        {body}
      <OverlayTrigger
        placement="left"
        overlay={<Tooltip>Add a new Product</Tooltip>}
      >
        <Button
          className="btn-floating"
          onClick={setShowAddProductModal.bind(this, true)}
        >
          <img src={AddIcon} alt="add-product" width="60" height="60" />
        </Button>
      </OverlayTrigger>
      <AddProductModel />
      {productSelect !== null && <UpdateProductModel />}
      <Toast
        show={show}
        style={{ position: "fixed", top: "20%", right: "10px" }}
        className={`bg-${type} text-white`}
        onClose={setShowToast.bind(this, {
          show: false,
          message: "",
          type: null,
        })}
        delay={3000}
        autohide
        animation={true}
      >
        <Toast.Body>
          <strong>{message}</strong>
        </Toast.Body>
      </Toast>
    </div>
  );
};

export default ProductManage;
