from flask import Flask, request, jsonify
import mysql.connector
import psycopg2
import time

app = Flask(__name__)
rds_conn = mysql.connector.connect(host='database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com', port=3306,
                                   user='admin', password='W136692850390d', database='Instacart')
redshift_conn = psycopg2.connect('dbname=knight9 host=redshift-cluster-1.cae6ybtaoioy.us-east-2.redshift.amazonaws.com\
    port=5439 user=knight9 password=W136692850390d')


def ok(data={}, **kwargs):
    response = {
        'status': 0,
        'message': 'ok',
        'data': data
    }
    response.update(kwargs)
    return jsonify(response)


def error(message='error', status=-1, data={}, **kwargs):
    response = {
        'status': status,
        'message': message,
        'data': data
    }
    response.update(kwargs)
    return jsonify(response)


def sql_query_from_rds(query):
    try:
        rds_cursor = rds_conn.cursor()
        start_t = time.time()
        rds_cursor.execute(query)
        end_t = time.time()
        columns = rds_cursor.column_names
        result = rds_cursor.fetchall()
        return ok({'columns': columns, 'result': result, 'time_cost': '%.5fs' % (end_t - start_t)})
    except Exception as e:
        return error(data=['Error: {}'.format(e)], message='Error: {}'.format(e))
    finally:
        rds_cursor.close()


def sql_query_from_redshift(query):
    try:
        redshift_cursor = redshift_conn.cursor()
        start_t = time.time()
        redshift_cursor.execute(query)
        end_t = time.time()
        columns = list(map(lambda c: c.name, redshift_cursor.description))
        result = redshift_cursor.fetchall()
        return ok({'columns': columns, 'result': result, 'time_cost': '%.5fs' % (end_t - start_t)})
    except Exception as e:
        return error(data=['Error: {}'.format(e)], message='Error: {}'.format(e))
    finally:
        redshift_cursor.close()


@app.route('/sql/query', methods=['GET'])
def sql_query():
    data = request.json
    db_type = data.get('db_type', 'rds')
    query = data.get('query', '')
    if db_type == 'rds':
        return sql_query_from_rds(query)
    return sql_query_from_redshift(query)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
