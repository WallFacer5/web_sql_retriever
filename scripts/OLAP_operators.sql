-- table
select * from MyCube order by 1,2,3

--Our statement:
select * from MyCube order by 1,2,3;

--Query result:
+----------+--------+-----------+---------+
| ThisYear | Region | Product   | Sales   |
+----------+--------+-----------+---------+
|     2016 | USA    | Chai      |  288.00 |
|     2016 | USA    | Chai      |  259.20 |
|     2016 | USA    | Tofu      |  279.00 |
|     2016 | USA    | Tofu      |  781.20 |
|     2017 | Canada | Chai      |  360.00 |
|     2017 | UK     | Chai      |  144.00 |
|     2017 | UK     | Chocolade |  153.00 |
|     2017 | USA    | Chai      |   90.00 |
|     2017 | USA    | Tofu      |  697.50 |
|     2017 | USA    | Tofu      |   69.75 |
|     2018 | Canada | Chai      | 1080.00 |
|     2018 | UK     | Chai      |  720.00 |
|     2018 | UK     | Chai      |  450.00 |
|     2018 | USA    | Chai      | 1440.00 |
|     2018 | USA    | Chai      |   72.00 |
|     2018 | USA    | Chai      |  144.00 |
|     2018 | USA    | Chai      |  810.00 |
|     2018 | USA    | Tofu      |   23.25 |
+----------+--------+-----------+---------+
 
-- pivot query
select
	Product, Q1, Q2, Q3, Q4
from
	MyCube PIVOT(SUM(Sales) FOR ThisQuarter IN (Q1,Q2,Q3,Q4)) AS P

--Our statement:
select
	Product,
	SUM(IF(ThisYear=2016, Sales, 0)) '2016',
	SUM(IF(ThisYear=2017, Sales, 0)) '2017',
	SUM(IF(ThisYear=2018, Sales, 0)) '2018'
from
	MyCube
group by
    Product;

--Query result:
+-----------+---------+--------+---------+
| Product   | 2016    | 2017   | 2018    |
+-----------+---------+--------+---------+
| Chai      |  547.20 | 594.00 | 4716.00 |
| Tofu      | 1060.20 | 767.25 |   23.25 |
| Chocolade |    0.00 | 153.00 |    0.00 |
+-----------+---------+--------+---------+

-- pivot query 
select
	Region, Q1, Q2, Q3, Q4
from
	MyCube PIVOT(SUM(Sales) FOR ThisQuarter IN (Q1,Q2,Q3,Q4)) AS P

--Our statement:
select
	Region,
	SUM(IF(ThisYear=2016, Sales, 0)) '2016',
	SUM(IF(ThisYear=2017, Sales, 0)) '2017',
	SUM(IF(ThisYear=2018, Sales, 0)) '2018'
from
	MyCube
group by
    Region;

--Query result:
+--------+---------+--------+---------+
| Region | 2016    | 2017   | 2018    |
+--------+---------+--------+---------+
| USA    | 1607.40 | 857.25 | 2489.25 |
| UK     |    0.00 | 297.00 | 1170.00 |
| Canada |    0.00 | 360.00 | 1080.00 |
+--------+---------+--------+---------+

-- pivot query
SELECT Product, Region, Q1, Q2, Q3, Q4
FROM   
(SELECT Product, Region, ThisQuarter, Sales FROM MyCube) AS p  
PIVOT  
(sum(Sales) FOR ThisQuarter IN (Q1,Q2,Q3,Q4)) AS pvt  

--Our statement:
select
	Product, Region,
	SUM(IF(ThisYear=2016, Sales, 0)) '2016',
	SUM(IF(ThisYear=2017, Sales, 0)) '2017',
	SUM(IF(ThisYear=2018, Sales, 0)) '2018'
from
	MyCube
group by
    Product, Region;

--Query result:
+-----------+--------+---------+--------+---------+
| Product   | Region | 2016    | 2017   | 2018    |
+-----------+--------+---------+--------+---------+
| Chai      | USA    |  547.20 |  90.00 | 2466.00 |
| Tofu      | USA    | 1060.20 | 767.25 |   23.25 |
| Chocolade | UK     |    0.00 | 153.00 |    0.00 |
| Chai      | Canada |    0.00 | 360.00 | 1080.00 |
| Chai      | UK     |    0.00 | 144.00 | 1170.00 |
+-----------+--------+---------+--------+---------+

-- slicing
select * from MyCube where ThisQuarter='Q1'

--Our statement:
select * from MyCube where ThisYear=2016;

--Query result:
+----------+--------+---------+--------+
| ThisYear | Region | Product | Sales  |
+----------+--------+---------+--------+
|     2016 | USA    | Chai    | 259.20 |
|     2016 | USA    | Chai    | 288.00 |
|     2016 | USA    | Tofu    | 279.00 |
|     2016 | USA    | Tofu    | 781.20 |
+----------+--------+---------+--------+

-- dicing
select * from MyCube where ThisQuarter='Q1' and region='Europe'

--Our statement:
select * from MyCube where ThisYear='2017' and region='Canada';

--Query result:
+----------+--------+---------+--------+
| ThisYear | Region | Product | Sales  |
+----------+--------+---------+--------+
|     2017 | Canada | Chai    | 360.00 |
+----------+--------+---------+--------+

-- group by with rollup
SELECT ThisQuarter, Region, Product, SUM(Sales) as TotalSales--, GROUPING(ThisQuarter) AS 'Grouping'
FROM MyCube
GROUP BY ThisQuarter, Region, Product with rollup
ORDER BY 1,2,3

--Our statement:
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales, GROUPING(ThisYear) AS 'Grouping'
FROM MyCube
GROUP BY ThisYear, Region, Product with rollup
ORDER BY 1,2,3;

--Query result:
+----------+--------+-----------+------------+----------+
| ThisYear | Region | Product   | TotalSales | Grouping |
+----------+--------+-----------+------------+----------+
|     NULL | NULL   | NULL      |    7860.90 |        1 |
|     2016 | NULL   | NULL      |    1607.40 |        0 |
|     2016 | USA    | NULL      |    1607.40 |        0 |
|     2016 | USA    | Chai      |     547.20 |        0 |
|     2016 | USA    | Tofu      |    1060.20 |        0 |
|     2017 | NULL   | NULL      |    1514.25 |        0 |
|     2017 | Canada | NULL      |     360.00 |        0 |
|     2017 | Canada | Chai      |     360.00 |        0 |
|     2017 | UK     | NULL      |     297.00 |        0 |
|     2017 | UK     | Chai      |     144.00 |        0 |
|     2017 | UK     | Chocolade |     153.00 |        0 |
|     2017 | USA    | NULL      |     857.25 |        0 |
|     2017 | USA    | Chai      |      90.00 |        0 |
|     2017 | USA    | Tofu      |     767.25 |        0 |
|     2018 | NULL   | NULL      |    4739.25 |        0 |
|     2018 | Canada | NULL      |    1080.00 |        0 |
|     2018 | Canada | Chai      |    1080.00 |        0 |
|     2018 | UK     | NULL      |    1170.00 |        0 |
|     2018 | UK     | Chai      |    1170.00 |        0 |
|     2018 | USA    | NULL      |    2489.25 |        0 |
|     2018 | USA    | Chai      |    2466.00 |        0 |
|     2018 | USA    | Tofu      |      23.25 |        0 |
+----------+--------+-----------+------------+----------+

-- group by with cube
SELECT ThisQuarter, Region, Product, SUM(Sales) as TotalSales--, GROUPING(ThisQuarter) AS 'Grouping'
FROM MyCube
GROUP BY ThisQuarter, Region, Product with cube
ORDER BY 1,2,3

--Our statement:
SELECT * FROM
(
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY ThisYear, Region, Product with rollup
union
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY ThisYear, Product, Region with rollup
union
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY Region, ThisYear, Product with rollup
union
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY Region, Product, ThisYear with rollup
union
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY Product, ThisYear, Region with rollup
union
SELECT ThisYear, Region, Product, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY Product, Region, ThisYear with rollup
) c
ORDER BY 1,2,3;

--Query result:
+----------+--------+-----------+------------+
| ThisYear | Region | Product   | TotalSales |
+----------+--------+-----------+------------+
|     NULL | NULL   | NULL      |    7860.90 |
|     NULL | NULL   | Chai      |    5857.20 |
|     NULL | NULL   | Chocolade |     153.00 |
|     NULL | NULL   | Tofu      |    1850.70 |
|     NULL | Canada | NULL      |    1440.00 |
|     NULL | Canada | Chai      |    1440.00 |
|     NULL | UK     | NULL      |    1467.00 |
|     NULL | UK     | Chai      |    1314.00 |
|     NULL | UK     | Chocolade |     153.00 |
|     NULL | USA    | NULL      |    4953.90 |
|     NULL | USA    | Chai      |    3103.20 |
|     NULL | USA    | Tofu      |    1850.70 |
|     2016 | NULL   | NULL      |    1607.40 |
|     2016 | NULL   | Chai      |     547.20 |
|     2016 | NULL   | Tofu      |    1060.20 |
|     2016 | USA    | NULL      |    1607.40 |
|     2016 | USA    | Chai      |     547.20 |
|     2016 | USA    | Tofu      |    1060.20 |
|     2017 | NULL   | NULL      |    1514.25 |
|     2017 | NULL   | Chai      |     594.00 |
|     2017 | NULL   | Chocolade |     153.00 |
|     2017 | NULL   | Tofu      |     767.25 |
|     2017 | Canada | NULL      |     360.00 |
|     2017 | Canada | Chai      |     360.00 |
|     2017 | UK     | NULL      |     297.00 |
|     2017 | UK     | Chai      |     144.00 |
|     2017 | UK     | Chocolade |     153.00 |
|     2017 | USA    | NULL      |     857.25 |
|     2017 | USA    | Chai      |      90.00 |
|     2017 | USA    | Tofu      |     767.25 |
|     2018 | NULL   | NULL      |    4739.25 |
|     2018 | NULL   | Chai      |    4716.00 |
|     2018 | NULL   | Tofu      |      23.25 |
|     2018 | Canada | NULL      |    1080.00 |
|     2018 | Canada | Chai      |    1080.00 |
|     2018 | UK     | NULL      |    1170.00 |
|     2018 | UK     | Chai      |    1170.00 |
|     2018 | USA    | NULL      |    2489.25 |
|     2018 | USA    | Chai      |    2466.00 |
|     2018 | USA    | Tofu      |      23.25 |
+----------+--------+-----------+------------+

-- group by grouping sets
SELECT ThisQuarter, Region, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY GROUPING SETS ((ThisQuarter), (Region))
ORDER BY 1,2

--Our statement:
SELECT ThisYear, Region, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY ThisYear, Region
union
SELECT ThisYear, NULL, SUM(Sales) as TotalSales
FROM MyCube
GROUP BY ThisYear
ORDER BY 1,2;

--Query result:
+----------+--------+------------+
| ThisYear | Region | TotalSales |
+----------+--------+------------+
|     2016 | NULL   |    1607.40 |
|     2016 | USA    |    1607.40 |
|     2017 | NULL   |    1514.25 |
|     2017 | Canada |     360.00 |
|     2017 | UK     |     297.00 |
|     2017 | USA    |     857.25 |
|     2018 | NULL   |    4739.25 |
|     2018 | Canada |    1080.00 |
|     2018 | UK     |    1170.00 |
|     2018 | USA    |    2489.25 |
+----------+--------+------------+

--
SELECT ThisQuarter, NULL as Region, SUM(Sales) as TotalSales FROM MyCube GROUP BY ThisQuarter
UNION ALL
SELECT NULL, Region, SUM(Sales) as TotalSales FROM MyCube GROUP BY Region
ORDER BY 1,2

--Our statement:
SELECT ThisYear, NULL as Region, SUM(Sales) as TotalSales FROM MyCube GROUP BY ThisYear
UNION ALL
SELECT NULL, Region, SUM(Sales) as TotalSales FROM MyCube GROUP BY Region
ORDER BY 1,2;

--Query result:
+----------+--------+------------+
| ThisYear | Region | TotalSales |
+----------+--------+------------+
|     NULL | Canada |    1440.00 |
|     NULL | UK     |    1467.00 |
|     NULL | USA    |    4953.90 |
|     2016 | NULL   |    1607.40 |
|     2017 | NULL   |    1514.25 |
|     2018 | NULL   |    4739.25 |
+----------+--------+------------+

-- Ranking
SELECT 
	Product, Sales
	, RANK() OVER (ORDER BY Sales ASC) as RANK_SALES
	, DENSE_RANK() OVER (ORDER BY Sales ASC) as DENSE_RANK_SALES
	, PERCENT_RANK() OVER (ORDER BY Sales ASC) as PERC_RANK_SALES
	, CUME_DIST() OVER (ORDER BY Sales ASC) as CUM_DIST_SALES
FROM 
	MyCube
ORDER BY 
	RANK_SALES ASC

--Our statement:
SELECT
	Product, Sales
	, RANK() OVER (ORDER BY Sales ASC) as RANK_SALES
	, DENSE_RANK() OVER (ORDER BY Sales ASC) as DENSE_RANK_SALES
	, PERCENT_RANK() OVER (ORDER BY Sales ASC) as PERC_RANK_SALES
	, CUME_DIST() OVER (ORDER BY Sales ASC) as CUM_DIST_SALES
FROM
	MyCube
ORDER BY
	RANK_SALES ASC;

--Query result:
+-----------+---------+------------+------------------+----------------------+---------------------+
| Product   | Sales   | RANK_SALES | DENSE_RANK_SALES | PERC_RANK_SALES      | CUM_DIST_SALES      |
+-----------+---------+------------+------------------+----------------------+---------------------+
| Tofu      |   23.25 |          1 |                1 |                    0 | 0.05555555555555555 |
| Tofu      |   69.75 |          2 |                2 | 0.058823529411764705 |  0.1111111111111111 |
| Chai      |   72.00 |          3 |                3 |  0.11764705882352941 | 0.16666666666666666 |
| Chai      |   90.00 |          4 |                4 |  0.17647058823529413 |  0.2222222222222222 |
| Chai      |  144.00 |          5 |                5 |  0.23529411764705882 |  0.3333333333333333 |
| Chai      |  144.00 |          5 |                5 |  0.23529411764705882 |  0.3333333333333333 |
| Chocolade |  153.00 |          7 |                6 |  0.35294117647058826 |  0.3888888888888889 |
| Chai      |  259.20 |          8 |                7 |   0.4117647058823529 |  0.4444444444444444 |
| Tofu      |  279.00 |          9 |                8 |  0.47058823529411764 |                 0.5 |
| Chai      |  288.00 |         10 |                9 |   0.5294117647058824 |  0.5555555555555556 |
| Chai      |  360.00 |         11 |               10 |   0.5882352941176471 |  0.6111111111111112 |
| Chai      |  450.00 |         12 |               11 |   0.6470588235294118 |  0.6666666666666666 |
| Tofu      |  697.50 |         13 |               12 |   0.7058823529411765 |  0.7222222222222222 |
| Chai      |  720.00 |         14 |               13 |   0.7647058823529411 |  0.7777777777777778 |
| Tofu      |  781.20 |         15 |               14 |   0.8235294117647058 |  0.8333333333333334 |
| Chai      |  810.00 |         16 |               15 |   0.8823529411764706 |  0.8888888888888888 |
| Chai      | 1080.00 |         17 |               16 |   0.9411764705882353 |  0.9444444444444444 |
| Chai      | 1440.00 |         18 |               17 |                    1 |                   1 |
+-----------+---------+------------+------------------+----------------------+---------------------+

-- Windowing
SELECT 
	ThisQuarter, Region, Sales
	, AVG(Sales) OVER (PARTITION BY Region ORDER BY ThisQuarter) AS Sales_Avg
FROM 
	MyCube
ORDER BY 
	Region, ThisQuarter, Sales_Avg

--Our statement:
SELECT
	ThisYear, Region, Sales
	, AVG(Sales) OVER (PARTITION BY Region ORDER BY ThisYear) AS Sales_Avg
FROM
	MyCube
ORDER BY
	Region, ThisYear, Sales_Avg;

--Query result:
+----------+--------+---------+------------+
| ThisYear | Region | Sales   | Sales_Avg  |
+----------+--------+---------+------------+
|     2017 | Canada |  360.00 | 360.000000 |
|     2018 | Canada | 1080.00 | 720.000000 |
|     2017 | UK     |  153.00 | 148.500000 |
|     2017 | UK     |  144.00 | 148.500000 |
|     2018 | UK     |  720.00 | 366.750000 |
|     2018 | UK     |  450.00 | 366.750000 |
|     2016 | USA    |  781.20 | 401.850000 |
|     2016 | USA    |  279.00 | 401.850000 |
|     2016 | USA    |  288.00 | 401.850000 |
|     2016 | USA    |  259.20 | 401.850000 |
|     2017 | USA    |  697.50 | 352.092857 |
|     2017 | USA    |   69.75 | 352.092857 |
|     2017 | USA    |   90.00 | 352.092857 |
|     2018 | USA    | 1440.00 | 412.825000 |
|     2018 | USA    |   72.00 | 412.825000 |
|     2018 | USA    |  144.00 | 412.825000 |
|     2018 | USA    |  810.00 | 412.825000 |
|     2018 | USA    |   23.25 | 412.825000 |
+----------+--------+---------+------------+

-- Windowing
SELECT 
	ThisQuarter, Region, Sales
	, AVG(Sales) OVER (PARTITION BY Region ORDER BY ThisQuarter ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS Sales_Avg
FROM 
	MyCube
ORDER BY 
	Region, ThisQuarter, Sales_Avg

--Our statement:
SELECT
	ThisYear, Region, Sales
	, AVG(Sales) OVER (PARTITION BY Region ORDER BY ThisYear ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS Sales_Avg
FROM
	MyCube
ORDER BY
	Region, ThisYear, Sales_Avg;

--Query result:
+----------+--------+---------+------------+
| ThisYear | Region | Sales   | Sales_Avg  |
+----------+--------+---------+------------+
|     2017 | Canada |  360.00 | 720.000000 |
|     2018 | Canada | 1080.00 | 720.000000 |
|     2017 | UK     |  153.00 | 148.500000 |
|     2017 | UK     |  144.00 | 339.000000 |
|     2018 | UK     |  720.00 | 438.000000 |
|     2018 | UK     |  450.00 | 585.000000 |
|     2016 | USA    |  259.20 | 273.600000 |
|     2016 | USA    |  288.00 | 275.400000 |
|     2016 | USA    |  279.00 | 449.400000 |
|     2016 | USA    |  781.20 | 585.900000 |
|     2017 | USA    |   69.75 | 285.750000 |
|     2017 | USA    |  697.50 | 516.150000 |
|     2017 | USA    |   90.00 | 533.250000 |
|     2018 | USA    |  810.00 | 325.750000 |
|     2018 | USA    |  144.00 | 342.000000 |
|     2018 | USA    |   23.25 | 416.625000 |
|     2018 | USA    | 1440.00 | 534.000000 |
|     2018 | USA    |   72.00 | 552.000000 |
+----------+--------+---------+------------+
