import React from "react";
import { Row, Col, Card, Badge } from "react-bootstrap";
import ActionButtons from "../layout/ActionButtons";

const Products = ({
  products: { _id, title, price, date, image, categories },
  idx,
}) => {
  let test = new Date(date);
  return (
    <tr>
      <td>{idx + 1}</td>
      <td>
        <img
          src={`http://localhost:5000/${image}`}
          alt={title}
          className="productImage"
        />
      </td>
      <td>{title}</td>
      <td>{price}</td>
      <td>{categories.join("| ")}</td>
      <td>{test.toString().substr(0, 24)}</td>
      <ActionButtons _id={_id} />
    </tr>
  );
};

export default Products;
