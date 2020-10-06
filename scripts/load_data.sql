load data local infile 'aisles.csv' into table AISLES fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'departments.csv' into table DEPARTMENTS fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'orders.csv' into table ORDERS fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'products.csv' into table PRODUCTS fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'order_products.csv' into table Order_Products fields terminated by ',' lines terminated by '\n' ignore 1 lines;