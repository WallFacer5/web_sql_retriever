CURRENT_PATH=$(pwd)
USER_ROOT=/home/$(whoami)
rm -rf $USER_ROOT/gse
mkdir $USER_ROOT/gse
cd $USER_ROOT/gse
aws s3 cp s3://knightbucket9/GSE13355/ ./ --recursive
aws s3 cp s3://knightbucket9/GSE13355/ ./ --recursive
mongoimport --uri mongodb+srv://knight:W136692850390d@cluster0.mhkup.mongodb.net/GSE13355 --collection targets --type csv --headerline --ignoreBlanks --file GSE13355_targets.csv
mongoimport --uri mongodb+srv://knight:W136692850390d@cluster0.mhkup.mongodb.net/GSE13355 --collection expr --type csv --headerline --ignoreBlanks --file GSE13355_expr_transpose.csv

cd $CURRENT_PATH
mysql -h database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com -P 3306 -u admin --local-infile -pW136692850390d -D GSE13355 < scripts/create_gse.sql
cd $USER_ROOT/gse/split_csv
mysql -h database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com -P 3306 -u admin --local-infile -pW136692850390d -D GSE13355 < $CURRENT_PATH/scripts/load_gse.sql
