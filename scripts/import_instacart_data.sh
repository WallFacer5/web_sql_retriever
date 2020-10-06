CURRENT_PATH=$(pwd)
USER_ROOT=/home/$(whoami)
rm -rf $USER_ROOT/Instacart
mkdir $USER_ROOT/Instacart
cd $USER_ROOT/Instacart
aws s3 cp s3://knightbucket9/Instacart/aisles.csv ./
aws s3 cp s3://knightbucket9/Instacart/departments.csv ./
aws s3 cp s3://knightbucket9/Instacart/order_products.csv ./
aws s3 cp s3://knightbucket9/Instacart/orders.csv ./
aws s3 cp s3://knightbucket9/Instacart/products.csv ./
cd $CURRENT_PATH
mysql -h database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com -P 3306 -u admin --local-infile -pW136692850390d -D Instacart < scripts/create_table.sql
cd $USER_ROOT/Instacart
mysql -h database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com -P 3306 -u admin --local-infile -pW136692850390d -D Instacart < $CURRENT_PATH/scripts/load_data.sql