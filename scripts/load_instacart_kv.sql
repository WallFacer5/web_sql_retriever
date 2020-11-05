insert into AISLES_KV select concat(aisle_id) as k, json_object('aisle', aisle) as v from AISLES;
insert into DEPARTMENTS_KV select concat(department_id) as k, json_object('department', department) as v from DEPARTMENTS;
insert into ORDERS_KV select concat(order_id) as k, json_object('user_id', user_id, 'order_number', order_number, 'order_dow', order_dow, 'order_hour_of_day', order_hour_of_day, 'days_since_prior_order', days_since_prior_order) as v from ORDERS;
insert into PRODUCTS_KV select concat(product_id) as k, json_object('product_name', product_name, 'aisle_id', aisle_id, 'department_id', department_id) as v from PRODUCTS;
insert into Order_Products_KV select concat(order_id, ',', product_id) as k, json_object('add_to_cart_order', add_to_cart_order, 'reordered', reordered) as v from Order_Products;