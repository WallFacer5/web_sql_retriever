load data local infile 'employee.txt' into table Employee fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'product.txt' into table Product fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'customer.txt' into table Customer fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'order.txt' into table Orders fields terminated by ',' lines terminated by '\n' ignore 1 lines;
load data local infile 'order_products.txt' into table Order_Products fields terminated by ',' lines terminated by '\n' ignore 1 lines;