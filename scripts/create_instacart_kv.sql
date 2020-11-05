create table AISLES_KV ( k varchar(20) not null, v json not null, primary key (k) );
create table DEPARTMENTS_KV ( k varchar(20) not null, v json not null, primary key (k) );
create table ORDERS_KV ( k varchar(20) not null, v json not null, primary key (k) );
create table PRODUCTS_KV ( k varchar(20) not null, v json not null, primary key (k) );
create table Order_Products_KV ( k varchar(20) not null, v json not null, primary key (k) );