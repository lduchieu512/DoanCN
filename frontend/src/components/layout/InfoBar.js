import React, { useState, useContext } from "react";
import Form from "react-bootstrap/Form";
import { motion } from "framer-motion";

import MoneyBag from "../../assets/icon-moneybag.svg";
import Transactions from "../../assets/icon-transaction.svg";
import Calendar from "../../assets/icon-date.svg";
import { BillContext } from "../../contexts/BillContext";

const cardVariants = {
  hidden: {
    opacity: 0,
  },
  visible: (i) => ({
    opacity: 1,
    transition: {
      delay: i * 0.25,
      duration: 0.25,
    },
  }),
};

const InfoBar = (bills) => {
  const { updateDateBills } = useContext(BillContext);
  const [date, setDate] = useState(new Date());
  let total = 0;
  if (bills) {
    let rock = 0;
    bills.bills.map((bill) => {
      rock = rock + bill.total;
      return null;
    });
    total = rock;
  }
  const setChange = (e) => {
    setDate(e.target.value);
    updateDateBills({ date: e.target.value });
  };

  return (
    <div className="Info-Container">
      <motion.div
        variants={cardVariants}
        initial="hidden"
        animate="visible"
        custom={1}
        className="Info-TotalBills"
      >
        <div className="Icon">
          <img width={70} height={70} src={Transactions} alt="Total Orders" />
        </div>
        <div className="Text-Container">
          <h2>Total Orders</h2>
          <div className="Content">{bills.bills.length}</div>
        </div>
      </motion.div>
      <motion.div
        variants={cardVariants}
        initial="hidden"
        animate="visible"
        custom={2}
        className="Info-TotalEarn"
      >
        <div className="Icon">
          <img width={70} height={70} src={MoneyBag} alt="Earning" />
        </div>
        <div className="Text-Container">
          <h2>Earning</h2>
          <div className="Content">{total} USD</div>
        </div>
      </motion.div>
      <motion.div
        variants={cardVariants}
        initial="hidden"
        animate="visible"
        custom={3}
        className="Info-Function"
      >
        <div className="Icon">
          <img width={70} height={70} src={Calendar} alt="Calendar" />
        </div>
        <div className="Date-Container">
          <Form.Control
            type="date"
            name="date-from"
            value={date}
            onChange={setChange}
          />
        </div>
      </motion.div>
    </div>
  );
};

export default InfoBar;
