import { useContext, useEffect } from "react";
import { Spinner, Row, Card } from "react-bootstrap";
import { motion } from "framer-motion";

import { BillContext } from "../contexts/BillContext";
import { AuthContext } from "../contexts/AuthContext";
import Bill from "../components/products/Bill";
import InfoBar from "../components/layout/InfoBar";

const Bills = () => {
  const {
    authState: { user },
  } = useContext(AuthContext);
  const {
    billState: { billLoading, bill },
    getBills,
  } = useContext(BillContext);

  useEffect(() => {
    getBills();
  }, [user, billLoading]);

  let body = null;
  let loadData = () => {
    if (billLoading) {
      body = (
        <div className="spinner-container">
          <Spinner animation="border" variant="info" />
        </div>
      );
    } else {
      if (bill.length === 0) {
        body = (
          <>
            <Card className="text-center mx-5 my-5">
              <Card.Header as="h1">Doesn't have any order yet!</Card.Header>
            </Card>
          </>
        );
      } else {
        body = (
          <>
            <Row className="row-cols-1 row-cols-md-3 g-4 mx-auto mt-3">
              {bill.map((billdetail) => {
                return <Bill bills={billdetail} />;
              })}
            </Row>
          </>
        );
      }
    }
  };
  loadData();

  return (
    <div style={{ marginLeft: "320px" }}>
      {bill && <InfoBar bills={bill} />}
      {body}
    </div>
  );
};

export default Bills;
