table_map = {
    'aisles': 'AISLES',
    'departments': 'DEPARTMENTS',
    'orders': 'ORDERS',
    'order products': 'Order_Products',
    'products': 'PRODUCTS'
}

operator_map = {
    "doesn't equal to": '!=',
    'is no less than': '>=',
    'is no more than': '<=',
    'is smaller than': '<',
    'is greater than': '>',
    'equals to': '='
}


aggregation_map = {
    'average': 'avg'
}


def map_table(tb):
    return table_map.get(tb, tb)


def map_attr(attr):
    if not attr:
        return attr
    return attr.replace(' ', '_')


def map_operator(operator):
    return operator_map.get(operator, operator)


def map_aggregation(aggr):
    return aggregation_map.get(aggr, aggr)
