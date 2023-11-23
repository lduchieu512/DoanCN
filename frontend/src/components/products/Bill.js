import React from "react";
import { Row, Col, Card, Badge } from "react-bootstrap";
import Billitem from "../products/BillItem";
import BillActionButton from "../layout/BillActionButton";
import avatar from "../../assets/3551739.jpg";

const Bill = ({ bills: { date, products, total, _id, status } }) => {
  let test = new Date(date);
  let productsLength =
    products[0] === null || products[0] === undefined
      ? products[0].length
      : products.length;
  return (
    <Col key={_id} className="my-2">
      <Card
        style={{ height: "100%" }}
        className="shadow"
        border={
          status === "Accepted"
            ? "success"
            : status === "Rejected"
            ? "danger"
            : "warning"
        }
      >
        <Card.Body>
          <Card.Title style={{ height: "100%" }}>
            <Row style={{ height: "100%" }}>
              <Col>
                <Row>
                  <Col sm={8}>
                    <Col className="bill-id">Order</Col>
                    <Col className="bill-date">
                      {test.toString().substr(0, 24)}
                    </Col>
                    <Col className="bill-address">13 St Marks street</Col>
                  </Col>
                  <Col sm={4}>
                    {/* <img className="bill-image" alt="avatar" src={avatar} /> */}
                  </Col>
                </Row>
              </Col>
              {products.map((product) => {
                return <Billitem products={product} />;
              })}
              <Col className="margintop full">
                <Row
                  className="full"
                  style={{
                    justifyContent: "space-between",
                    height: "100%",
                    alignItems: "flex-end",
                  }}
                >
                  <Col sm={6}>
                    <Col className="bill-itemscount">
                      X{productsLength} items
                    </Col>
                    <Col>
                      <Badge
                        pill
                        variant="secondary"
                        className="bill-totalprice"
                      >
                        ${total}
                      </Badge>
                    </Col>
                  </Col>
                  <Col sm={6} className="text-right">
                    <BillActionButton _id={_id} status={status} />
                  </Col>
                </Row>
              </Col>
            </Row>
          </Card.Title>
        </Card.Body>
      </Card>
    </Col>
  );
};

export default Bill;
