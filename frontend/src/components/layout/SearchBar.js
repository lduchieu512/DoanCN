import React, { useContext, useState, useCallback } from "react";
import { Row, Col, Form, FormGroup } from "react-bootstrap";
import { motion } from "framer-motion";

import { ProductContext } from "../../contexts/ProductContext";
import deBounce from "../../utils/deBounce";

const SearchBar = () => {
  const { filterProducts, getProducts } = useContext(ProductContext);

  const [query, setQuery] = useState("");

  const updateDebounce = useCallback(
    deBounce((text) => {
      console.log("running");
      if (text.length !== 0) filterProducts(text);
      else getProducts();
    }, 250),
    []
  );

  const onChange = (event) => {
    setQuery(event.target.value);
    updateDebounce(event.target.value);
  };
  return (
    <>
      <Row className="flex justify-content-center" style={{ marginTop: 10 }}>
        <Col sm={4}>
          <FormGroup>
            <Form.Control
              type="text"
              placeholder="Search here..."
              name="query"
              value={query}
              onChange={onChange}
            />
          </FormGroup>
        </Col>
      </Row>
    </>
  );
};

export default SearchBar;
