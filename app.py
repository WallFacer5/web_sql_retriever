from flask import Flask

app = Flask(__name__)


@app.route('/sql/query/rds', methods=['GET'])
def sql_query_from_rds():
    return 'Sql query!\n'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
