from flask import Flask, request, jsonify
import mysql.connector
import psycopg2
import time

app = Flask(__name__)
rds_conn = mysql.connector.connect(host='database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com', port=3306,
                                   user='admin', password='W136692850390d')
redshift_conn = psycopg2.connect('dbname=knight9 host=redshift-cluster-1.cae6ybtaoioy.us-east-2.redshift.amazonaws.com\
    port=5439 user=knight9 password=W136692850390d')
redshift_cursor = redshift_conn.cursor()


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
        query_l = query.replace('\t', ' ').replace('\n', ' ').replace('\r', ' ').replace(';',
                                                                                         ' ').strip().lower().split(' ')
        query_l = list(filter(lambda x: x != '', query_l))
        if query_l[0] == 'use':
            return ok(
                {'columns': ['Current database'], 'result': [{'Current database': query_l[1]}],
                 'time_cost': '%.5fs' % (end_t - start_t)})
        result = rds_cursor.fetchall()
        result = list(map(
            lambda r: {columns[i]: r[i].decode() if isinstance(r[i], bytearray) or isinstance(r[i], bytes) else r[i] for
                       i in range(len(columns))}, result))
        return ok({'columns': columns, 'result': result, 'time_cost': '%.5fs' % (end_t - start_t)})
    except Exception as e:
        columns = ['Error message']
        result = list(map(
            lambda r: {columns[i]: r[i].decode() if isinstance(r[i], bytearray) or isinstance(r[i], bytes) else r[i] for
                       i in range(len(columns))}, [['{}'.format(e)]]))
        return error(data={'columns': columns, 'result': result, 'time_cost': 'N/A'}, message='Error: {}'.format(e))
    finally:
        rds_cursor.close()


def sql_query_from_redshift(query):
    global redshift_cursor, redshift_conn
    try:
        start_t = time.time()
        redshift_cursor.execute(query)
        end_t = time.time()
        columns = list(map(lambda c: c.name, redshift_cursor.description))
        result = redshift_cursor.fetchall()
        result = list(map(lambda r: {columns[i]: r[i] for i in range(len(columns))}, result))
        return ok({'columns': columns, 'result': result, 'time_cost': '%.5fs' % (end_t - start_t)})
    except Exception as e:
        redshift_conn = psycopg2.connect('dbname=knight9 \
            host=redshift-cluster-1.cae6ybtaoioy.us-east-2.redshift.amazonaws.com \
            port=5439 user=knight9 password=W136692850390d')
        redshift_cursor = redshift_conn.cursor()
        columns = ['Error message']
        result = list(map(
            lambda r: {columns[i]: r[i].decode() if isinstance(r[i], bytearray) or isinstance(r[i], bytes) else r[i] for
                       i in range(len(columns))}, [['{}'.format(e)]]))
        return error(data={'columns': columns, 'result': result, 'time_cost': 'N/A'}, message='Error: {}'.format(e))


@app.route('/sql/query', methods=['POST'])
def sql_query():
    data = request.json
    db_type = data.get('db_type', 'rds')
    query = data.get('query', '')
    if db_type == 'rds':
        return sql_query_from_rds(query)
    return sql_query_from_redshift(query)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9123)
