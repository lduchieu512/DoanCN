import React from "react";
import { Row, Col, Image } from "react-bootstrap";
const Billitem = ({ products: { product, quantity, price } }) => {
  let productRender =
    product[0] !== null || product[0] !== undefined ? product[0] : product;
  return (
    <Row className="marginleft margintop">
      <Row>
        <Col sm={3}>
          <Image
            src={`http://localhost:5000/${productRender.image}`}
            alt={productRender.title}
            className="bill-image"
          />
        </Col>
        <Col sm={9}>
          <Col className="bill-id">{productRender.title}</Col>
          <Col>
            <Row>
              <Col>${price}</Col>
              <Col>Qty: {quantity}</Col>
            </Row>
          </Col>
        </Col>
      </Row>
    </Row>
  );
};

export default Billitem;
