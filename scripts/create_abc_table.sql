drop table Order_Products;
drop table Orders;
drop table Customer;
drop table Product;
drop table Employee;

CREATE TABLE Employee
(
  Employee_LastName VARCHAR(20) NOT NULL,
  Employee_FirstName VARCHAR(20) NOT NULL,
  Employee_Title VARCHAR(20) NOT NULL,
  CompanyName VARCHAR(20) NOT NULL,
  PRIMARY KEY (Employee_LastName),
  UNIQUE (Employee_FirstName)
);

CREATE TABLE Product
(
  ProductName VARCHAR(20) NOT NULL,
  Order_UnitPrice FLOAT NOT NULL,
  PRIMARY KEY (ProductName)
);

CREATE TABLE Customer
(
  Customer_ContactName VARCHAR(20) NOT NULL,
  Customer_City VARCHAR(20) NOT NULL,
  Customer_Country VARCHAR(20) NOT NULL,
  Customer_Phone VARCHAR(20) NOT NULL,
  PRIMARY KEY (Customer_ContactName)
);

CREATE TABLE Orders
(
  OrderID INT NOT NULL,
  OrderDate DATETIME NOT NULL,
  Order_ShippedDate DATETIME NOT NULL,
  Order_Freight FLOAT NOT NULL,
  Order_ShipCity VARCHAR(20) NOT NULL,
  Order_ShipCountry VARCHAR(20) NOT NULL,
  Employee_LastName VARCHAR(20) NOT NULL,
  Customer_ContactName VARCHAR(20) NOT NULL,
  PRIMARY KEY (OrderID),
  FOREIGN KEY (Employee_LastName) REFERENCES Employee(Employee_LastName),
  FOREIGN KEY (Customer_ContactName) REFERENCES Customer(Customer_ContactName)
);

CREATE TABLE Order_Products
(
  Order_Quantity INT NOT NULL,
  Order_Amount FLOAT NOT NULL,
  OrderID INT NOT NULL,
  ProductName VARCHAR(20) NOT NULL,
  PRIMARY KEY (OrderID, ProductName),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (ProductName) REFERENCES Product(ProductName)
);