import json
import re
import streamlit as st
from parse_sql import get_tablename,clean_comment
from moz_sql_parser import parse


              
def show_tree(sql):
    
    if sql:
        sql = clean_comment(sql)
        tree = parse(sql)
        st.json(tree)

        
toolbox = ['extract tablename from sql','moz_sql_parser','clean sql']
tool = st.sidebar.selectbox('function_select',toolbox) 

default_sql = '''WITH tmp_table 
AS (select * from tableA)
select * from tmp_table left join tableB
'''
if tool == 'extract tablename from sql':

    sql = st.text_area('SQL_INPUT',value=default_sql)
    if sql:
        all_table = []
        print(f"alltable1:{all_table}")
        all_table = get_tablename(sql)
        st.write(all_table)
        '''
        ## sinitek table level
        '''
        sditable, ctable, ttable, stable=[],[],[],[]
        table_level = [sditable, ctable, ttable, stable]
        table_level_name = ['SDI_tables', 'C_tables', 'T_tables', 'S_tables']
        for i in all_table:
            if i[0:3] == 'SDI':
                sditable.append(i)
            elif i[0] == 'S':
                stable.append(i)
            elif i[0] == 'T':
                ttable.append(i)
            elif i[0] == 'C':
                ctable.append(i)

        for i in range(len(table_level)):
            table_level[i].sort()
            st.write(table_level_name[i])
            st.write(table_level[i])

        all_table = []
        print(f"alltable2:{all_table}")


        '''
        ## json tree
        '''
        if st.button('show tree'):
            show_tree(sql)
    else:
        st.warning('Please Write a SQL tatement above ')
    
    '''
    ## source_code
    '''
    if st.button('show code'):
        with st.echo():
            from moz_sql_parser import parse
            import re


            token_list = ["from","union","union_all","join","cross_join",
              "left join","right join",
              "left outer join","right outer join",
              "full outer join","inner join","full join"]
            table_list = []
            tmp_list = []
            def clean_comment(sql):
                # 删除多行注释
                sql = re.sub(r"/\*[^*]*\*+(?:[^*/][^*]*\*+)*/", "", sql)
                # 删除独立一行注释
                lines = [line.upper() for line in sql.splitlines() if not re.match("^\s*(--|#)", line)]
                # 删除代码末尾行注释
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
                    if len(tmp_list)>0:
                        tmp_list = [table.upper() for table in tmp_list]
                        for i in table_list:
                            if i in tmp_list:
                                table_list.remove(i)
                    
                else:
                    return 'sql输入有误(Not Str)'
                return table_list

            if __name__=="__main__":
                sql = '''
                      with tmp_table as(
                        select * from tableA
                      )
                        select * from tmp_table left join tableB
                      '''
                get_tablename(sql)

elif tool == 'moz_sql_parser':
    sql = st.text_area('SQL_INPUT',value=default_sql)
    if sql:
        show_tree(sql)
    else:
        st.warning('Please Write a SQL tatement above ')

elif tool == 'clean sql':
    sql = st.text_area('SQL_INPUT',value=default_sql)
    if sql:
        sql = clean_comment(sql)
        st.write(sql)
    else:
        st.warning('Please Write a SQL tatement above ')
            

    


