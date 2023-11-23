import React, { useContext } from "react";
import { Button, Col, OverlayTrigger, Tooltip } from "react-bootstrap";
import AcceptedIcon from "../../assets/icon-accepted.svg";
import RejectedIcon from "../../assets/icon-rejected.svg";
import { BillContext } from "../../contexts/BillContext";

const BillActionButton = ({ _id, status }) => {
  const { updateBills } = useContext(BillContext);
  const update = (billId, billStatus) => {
    const sent = {
      _id: billId,
      status: billStatus,
    };
    updateBills(sent);
  };
  return (
    <>
      {status === "Waiting" && (
        <>
          <OverlayTrigger
            placement="left"
            overlay={<Tooltip>Accepted</Tooltip>}
          >
            <Button
              className="post-button"
              onClick={update.bind(this, _id, "Accepted")}
            >
              <img src={AcceptedIcon} alt="Accepted" width="24" height="24" />
            </Button>
          </OverlayTrigger>
          <OverlayTrigger
            placement="right"
            overlay={<Tooltip>Rejected</Tooltip>}
          >
            <Button
              className="post-button"
              onClick={update.bind(this, _id, "Rejected")}
            >
              <img
                src={RejectedIcon}
                alt="Rejected"
                width="24"
                height="24"
                className="icon-rejected"
              />
            </Button>
          </OverlayTrigger>
        </>
      )}
      {status === "Accepted" && (
        <>
          <Col className="bill-action-text accepted">
            <img src={AcceptedIcon} alt="Accepted" width={24} height={24} />
            {status}
          </Col>
        </>
      )}
      {status === "Rejected" && (
        <>
          <Col className="bill-action-text rejected">
            <img
              src={RejectedIcon}
              alt="Rejected"
              width={24}
              height={24}
              className="icon-rejected"
            />
            {status}
          </Col>
        </>
      )}
    </>
  );
};

export default BillActionButton;
