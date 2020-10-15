CURRENT_PATH=$(pwd)
USER_ROOT=/home/$(whoami)
rm -rf $USER_ROOT/ABC_Retail
mkdir $USER_ROOT/ABC_Retail
cd $USER_ROOT/ABC_Retail
aws s3 cp s3://knightbucket9/ABC_Retail/employee.txt ./
aws s3 cp s3://knightbucket9/ABC_Retail/product.txt ./
aws s3 cp s3://knightbucket9/ABC_Retail/customer.txt ./
aws s3 cp s3://knightbucket9/ABC_Retail/order.txt ./
aws s3 cp s3://knightbucket9/ABC_Retail/order_products.txt ./
cd $CURRENT_PATH
mysql -h database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com -P 3306 -u admin --local-infile -pW136692850390d -D ABC_Retail < scripts/create_abc_table.sql
cd $USER_ROOT/ABC_Retail
mysql -h database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com -P 3306 -u admin --local-infile -pW136692850390d -D ABC_Retail < $CURRENT_PATH/scripts/load_abc_data.sql