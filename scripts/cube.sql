CREATE TABLE ABC_Retail
(
  OrderID INT NOT NULL,
  OrderDate DATETIME NOT NULL,
  Order_ShippedDate DATETIME NOT NULL,
  Order_Freight DECIMAL(8,2) NOT NULL,
  Order_ShipCity VARCHAR(20) NOT NULL,
  Order_ShipCountry VARCHAR(20) NOT NULL,
  Order_UnitPrice DECIMAL(8,2) NOT NULL,
  Order_Quantity INT NOT NULL,
  Order_Amount DECIMAL(8,2) NOT NULL,
  ProductName VARCHAR(20) NOT NULL,
  Employee_LastName VARCHAR(20) NOT NULL,
  Employee_FirstName VARCHAR(20) NOT NULL,
  Employee_Title VARCHAR(20) NOT NULL,
  CompanyName VARCHAR(20) NOT NULL,
  Customer_ContactName VARCHAR(20) NOT NULL,
  Customer_City VARCHAR(20) NOT NULL,
  Customer_Country VARCHAR(20) NOT NULL,
  Customer_Phone VARCHAR(20) NOT NULL,
  PRIMARY KEY (OrderID, Employee_LastName, Employee_FirstName, ProductName, Customer_ContactName)
);

load data local infile 'ABC_Retail.txt' into table ABC_Retail fields terminated by '\t' lines terminated by '\n' ignore 1 lines;

--the code in the assignment instruction
select
    year(OrderDate) as ThisYear,
    Order_ShipCountry as Region,
    ProductName as Product,
    Order_Amount as Sales
into
    MyCube
from
    ABC_Retail
where
    Order_ShipCountry in ('USA','Canada','UK')
    and ProductName in ('Chai','Tofu','Chocolade');

--Our code
create table MyCube
(
    select
        year(OrderDate) as ThisYear,
        Order_ShipCountry as Region,
        ProductName as Product,
        Order_Amount as Sales
    from
        ABC_Retail
    where
        Order_ShipCountry in ('USA','Canada','UK')
        and ProductName in ('Chai','Tofu','Chocolade')
);
