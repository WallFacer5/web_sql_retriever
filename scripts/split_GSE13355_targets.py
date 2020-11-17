import pandas as pd
import argparse
import os
from os import path


def generate_sql(columns, num):
    sql = 'create table expr{}\n(\nid char(9) not null,\n<need_gen>,\nprimary key (id)\n);'.format(num)
    need_gen = map(lambda c: ' '.join(['`{}`'.format(c), 'decimal(8,6)', 'not null']), columns)
    need_gen = ',\n'.join(need_gen)
    return sql.replace('<need_gen>', need_gen)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--filepath', default='')
    args = parser.parse_args()
    filepath = args.filepath
    origin_d = pd.read_csv(filepath, header=0, index_col=0)
    transposed_d = origin_d.transpose()
    y_len = transposed_d.shape[1]
    y = 0
    slot = 1000
    out_path = path.join(path.split(filepath)[0], 'split_csv')
    if path.exists(out_path):
        os.remove(out_path)
    os.makedirs(out_path)
    pointers = []
    sqls = ['\n'.join(['create table pointers\n(', 'column_name varchar(35) not null,', 'table_num int not null,',
                       'primary key (column_name)\n);'])]
    load_data = [
        "load data local infile 'pointers.csv' into table pointers fields terminated by ',' lines terminated by '\\n';"]
    while y <= y_len:
        cur_file = path.join(out_path, 'col_{}_{}.csv'.format(y, y + slot))
        transposed_d.iloc[:, y:(y+slot)].to_csv(cur_file)
        cur_cols = transposed_d.iloc[:, y:(y + slot)].columns
        sql_create = generate_sql(cur_cols, y // 1000)
        cur_pointers = map(lambda c: ','.join([c, str(y // 1000)]), cur_cols)
        cur_load = \
            '''
load data local infile 'col_{}_{}.csv' into table expr{} fields terminated by ',' lines terminated by '\\n' 
ignore 1 lines;
        '''.format(y, y + slot, y // 1000).replace('\n', '')
        sqls.append(sql_create)
        pointers += list(cur_pointers)
        load_data.append(cur_load)
        y += slot
    pointers_file = path.join(out_path, 'pointers.csv')
    with open(pointers_file, 'w') as pf:
        pf.write('\n'.join(pointers))
    sql_file = path.join('scripts', 'create_gse.sql')
    with open(sql_file, 'w') as sf:
        sf.write('\n\n'.join(sqls))
    load_file = path.join('scripts', 'load_gse.sql')
    with open(load_file, 'w') as lf:
        lf.write('\n'.join(load_data))
