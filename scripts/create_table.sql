CREATE TABLE ORDERS
(
  order_id INT NOT NULL,
  user_id INT NOT NULL,
  order_number INT NOT NULL,
  order_dow INT NOT NULL,
  order_hour_of_day INT NOT NULL,
  days_since_prior_order INT NOT NULL,
  PRIMARY KEY (order_id)
);

CREATE TABLE AISLES
(
  aisle_id INT NOT NULL,
  aisle VARCHAR(35) NOT NULL,
  PRIMARY KEY (aisle_id),
  UNIQUE (aisle)
);

CREATE TABLE DEPARTMENTS
(
  department_id INT NOT NULL,
  department VARCHAR(20) NOT NULL,
  PRIMARY KEY (department_id),
  UNIQUE (department)
);

CREATE TABLE PRODUCTS
(
  product_id INT NOT NULL,
  product_name VARCHAR(160) NOT NULL,
  aisle_id INT NOT NULL,
  department_id INT NOT NULL,
  PRIMARY KEY (product_id),
  FOREIGN KEY (aisle_id) REFERENCES AISLES(aisle_id),
  FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

CREATE TABLE Order_Products
(
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  add_to_cart_order INT NOT NULL,
  reordered INT NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
  FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);