from flask import Flask, request, jsonify
import mysql.connector
import psycopg2
import time

from conf.instacart_conf import *

app = Flask(__name__)
rds_conn = mysql.connector.connect(host='database-knight9.ckranbftnjbu.us-east-2.rds.amazonaws.com', port=3306,
                                   user='admin', password='W136692850390d', database='Instacart')
redshift_conn = psycopg2.connect('dbname=knight9 host=redshift-cluster-1.cae6ybtaoioy.us-east-2.redshift.amazonaws.com\
    port=5439 user=knight9 password=W136692850390d')
redshift_cursor = redshift_conn.cursor()

current_columns = []
current_result = []
current_time_cost = 'N/A'
current_query = ''


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
    global rds_conn, current_columns, current_result, current_time_cost, current_query
    current_query = query
    try:
        rds_cursor = rds_conn.cursor()
        start_t = time.time()
        rds_cursor.execute(query)
        end_t = time.time()
        columns = list(rds_cursor.column_names)
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
        current_columns = [columns[-1]] + columns[:-1]
        current_result = result
        current_time_cost = '%.5fs' % (end_t - start_t)
        return ok({'columns': current_columns, 'result': result, 'time_cost': current_time_cost, 'query': query})
    except Exception as e:
        columns = ['Error message']
        result = list(map(
            lambda r: {columns[i]: r[i].decode() if isinstance(r[i], bytearray) or isinstance(r[i], bytes) else r[i] for
                       i in range(len(columns))}, [['{}'.format(e)]]))
        current_columns = [columns[-1]] + columns[:-1]
        current_result = result
        current_time_cost = 'N/A'
        return error(data={'columns': current_columns, 'result': result, 'time_cost': 'N/A', 'query': query},
                     message='Error: {}'.format(e))
    finally:
        try:
            rds_cursor.close()
        except Exception as e:
            print(e)
            pass


def sql_query_from_redshift(query):
    global redshift_cursor, redshift_conn
    try:
        start_t = time.time()
        redshift_cursor.execute(query)
        end_t = time.time()
        columns = list(map(lambda c: c.name, redshift_cursor.description))
        result = redshift_cursor.fetchall()
        result = list(map(lambda r: {columns[i]: r[i] for i in range(len(columns))}, result))
        return ok({'columns': [columns[-1]] + columns[:-1], 'result': result, 'time_cost': '%.5fs' % (end_t - start_t)})
    except Exception as e:
        redshift_conn = psycopg2.connect('dbname=knight9 \
            host=redshift-cluster-1.cae6ybtaoioy.us-east-2.redshift.amazonaws.com \
            port=5439 user=knight9 password=W136692850390d')
        redshift_cursor = redshift_conn.cursor()
        columns = ['Error message']
        result = list(map(
            lambda r: {columns[i]: r[i].decode() if isinstance(r[i], bytearray) or isinstance(r[i], bytes) else r[i] for
                       i in range(len(columns))}, [['{}'.format(e)]]))
        return error(data={'columns': [columns[-1]] + columns[:-1], 'result': result, 'time_cost': 'N/A'},
                     message='Error: {}'.format(e))


@app.route('/sql/query', methods=['POST'])
def sql_query():
    data = request.json
    db_type = data.get('db_type', 'rds')
    query = data.get('query', '')
    if db_type == 'rds':
        return sql_query_from_rds(query)
    return sql_query_from_redshift(query)


@app.route('/sql/test', methods=['POST'])
def sql_test():
    data = request.json
    print('received test request: {}'.format(data))
    return ok()


def generate_sql_statement(slots):
    attribute = slots.get('attribute', {}).get('value', 'star')
    attribute = '*' if attribute in ('star', None) else map_attr(attribute)
    attribute_b = map_attr(slots.get('attribute_b', {}).get('value', None))
    attribute_c = map_attr(slots.get('attribute_c', {}).get('value', None))
    attributes = ', '.join(filter(lambda a: a, [attribute, attribute_b, attribute_c]))
    aggregate = map_aggregation(slots.get('aggregate', {}).get('value', None))
    attribute_aggr = map_attr(slots.get('attribute_aggr', {}).get('value', None))
    table = map_table(slots.get('table', {}).get('value', '<tb>'))
    attribute_cond = map_attr(slots.get('attribute_cond', {}).get('value', None))
    where_op = map_operator(slots.get('where_op', {}).get('value', None))
    number_cond = slots.get('number_cond', {}).get('value', None)
    attribute_group_by = map_attr(slots.get('attribute_group_by', {}).get('value', None))
    attribute_order_by = map_attr(slots.get('attribute_order_by', {}).get('value', None))
    number_limit = slots.get('number_limit', {}).get('value', None)
    attribute_having = map_attr(slots.get('attribute_having', {}).get('value', None))
    having_op = map_operator(slots.get('having_op', {}).get('value', None))
    number_having = slots.get('number_having', {}).get('value', None)
    aggregate_having = map_aggregation(slots.get('aggregate_having', {}).get('value', None))
    aggregate_order = map_aggregation(slots.get('aggregate_order', {}).get('value', None))
    order_seq = slots.get('order_seq', {}).get('value', '')
    if not number_limit:
        number_limit = '20'
    if not attribute_group_by:
        select_part = 'select {} from {}'.format(attributes, table)
        if attribute_cond and where_op and number_cond:
            where_part = 'where {} {} {}'.format(attribute_cond, where_op, number_cond)
        else:
            where_part = ''
        if attribute_order_by:
            order_by_part = 'order by {} {}'.format(attribute_order_by, order_seq)
        else:
            order_by_part = ''
        limit_part = 'limit {}'.format(number_limit)
        statement = ' '.join([select_part, where_part, order_by_part, limit_part])
    else:
        select_part = 'select {}, {}({}) from {}'.format(attributes, aggregate, attribute_aggr, table)
        if attribute_cond and where_op and number_cond:
            where_part = 'where {} {} {}'.format(attribute_cond, where_op, number_cond)
        else:
            where_part = ''
        group_by_part = 'group by {}'.format(attribute_group_by)
        if attribute_having:
            if aggregate_having:
                having_part = 'having {}({}) {} {}'.format(aggregate_having, attribute_having, having_op, number_having)
            else:
                having_part = 'having {} {} {}'.format(attribute_having, having_op, number_having)
        else:
            having_part = ''
        if attribute_order_by:
            if aggregate_order:
                order_by_part = 'order by {}({}) {}'.format(aggregate_order, attribute_order_by, order_seq)
            else:
                order_by_part = 'order by {} {}'.format(attribute_order_by, order_seq)
        else:
            order_by_part = ''
        limit_part = 'limit {}'.format(number_limit)
        statement = ' '.join([select_part, where_part, group_by_part, having_part, order_by_part, limit_part])
    return statement


@app.route('/sql/query_by_voice', methods=['POST'])
def sql_query_by_voice():
    data = request.json
    slots = data['query']
    print(slots)
    sql_statement = generate_sql_statement(slots)
    print('Generated sql: {}'.format(sql_statement))
    return sql_query_from_rds(sql_statement)


@app.route('/sql/desc_by_voice', methods=['POST'])
def sql_desc_by_voice():
    data = request.json
    table = map_table(data['query'])
    print('Desc sql: desc {}'.format(table))
    return sql_query_from_rds('desc {}'.format(table))


@app.route('/sql/sync_results', methods=['GET'])
def sql_sync_results():
    return ok(
        {'columns': current_columns, 'result': current_result, 'time_cost': current_time_cost, 'query': current_query})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9123)
