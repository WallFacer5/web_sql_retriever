from flask import Flask

app = Flask(__name__)


@app.route('/sql/query', methods=['POST'])
def sql_query():
    return 'Sql query!\n'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
