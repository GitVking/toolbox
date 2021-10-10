#  pip install -i https://pypi.tuna.tsinghua.edu.cn/simple moz_sql_parser
# -*- coding: utf-8 -*-
# @Time    : 2021/08/29 
# @Author  : wyj

from moz_sql_parser import parse
import re

token_list = ["from","union","union_all","join","cross_join",
              "left join","right join",
              "left outer join","right outer join",
              "full outer join","inner join","full join"]
table_list = []
tmp_list = []
def clean_comment(sql):
    # delete /* */ comment 
    sql = re.sub(r"/\*[^*]*\*+(?:[^*/][^*]*\*+)*/", "", sql)
    # delete -- | # comment
    lines = [line.upper() for line in sql.splitlines() if not re.match("^\s*(--|#)", line)]
    # delete comment after sql of each line
    sql = " ".join([re.split("--|#", line)[0] for line in lines])
    sql = ' '.join(sql.split())
    return sql

def in_token(tree):
    for element in tree:
        if element == 'with':
            if isinstance(tree['with'],list):
                for element in tree['with']:
                    in_token(element)
            # with name
            for name in tree['with']:
                if name == 'name':
                    tmp_list.append(tree['with']['name'])
                elif isinstance(name,dict):
                    tmp_list.append(name['name'])
        elif element == 'value':
            if isinstance(tree['value'],str):
                get_str(tree['value'])
            else:
                in_token(tree['value'])
        elif element in token_list:
            if isinstance(tree[element],str):
                get_str(tree[element])
            elif isinstance(tree[element],list):
                get_list(tree[element])
            elif isinstance(tree[element],dict):
                get_dict(tree[element])
            else:
                print("#######")
                print(element)
                print("#######")
        else:
            print(f"{element}:Not In Token")

def get_str(element):
    table_list.append(element)

def get_list(element):
    for sub_element in element:
        if isinstance(sub_element,str):
            get_str(sub_element)
        else:
            in_token(sub_element)

def get_dict(element):
    in_token(element)

def get_tablename(sql):
    if isinstance(sql,str):
        sql = clean_comment(sql)
        # sql to json
        tree = parse(sql)
        #token
        in_token(tree)
        global table_list,tmp_list
        table_list = list(set(table_list))
        # print(f'tree:{tree}')
        # print("#############################")
        # print(f'table_list:{table_list}')
        # with: delete WithTableName in table_list
        if len(tmp_list)>0:
            tmp_list = [table.upper() for table in tmp_list]
            for i in table_list[:]:
                if i in tmp_list:
                    table_list.remove(i)
            tmp_list.sort()
            print(tmp_list)
        table_list.sort()
        return table_list
        
    else:
        return 'sql input is Not Str)'
    

if __name__=="__main__":
    sql="""
WITH tmp_table 
AS (select * from tableA)
select * from tmp_table 
               
"""
    print(get_tablename(sql))


