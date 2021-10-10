from moz_sql_parser import parse
import re

token_list = ["from","union","union_all","join","cross_join","with",
              "left join","right join",
              "left outer join","right outer join",
              "full outer join","inner join","full join"]
table_list = []
tmp_list = []
def clean_comment(sql):
    # delete /* */ comment 
    sql = re.sub(r"/\*[^*]*\*+(var:[^*/][^*]*\*+)*/", "", sql)
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
            if isinstance(tree['with'],dict):
                in_token(tree['with'])
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
WITH temp0 AS
  (--变量获取，由报表工具传入
 SELECT DISTINCT to_char(var, 'yyyymmdd') AS START_DT,
                 to_char(var, 'yyyymmdd') AS END_DT,
                 T2.SK_PROD AS PROD,
                 NVL(T2.FUND_BRIEF_NAME, T2.FUND_NAME) FUND_NAME
   FROM T00_PROD_PARM_ACCT_SET_INFO TA
   LEFT JOIN T02_PROD_BASICINFO T2 ON TA.PROD_CODE = T2.FUND_CODE
   LEFT JOIN T02_PROD_CATALOG TC ON T2.SK_PROD = TC.SK_F_PROD
   LEFT JOIN T02_PROD_LIFECYCLE T3 ON TC.SK_F_PROD = T3.SK_PROD
   WHERE TC.FUND_TYPE_METHOD = '23'
     AND TC.PROD_CLASS_TYPE IN ('2305',
                                '2303')
     AND T2.SK_PROD = T3.SK_PROD
     AND T3.FUND_FOUND_DT <= to_char(var, 'yyyymmdd')
     AND (T3.CLEAR_DT > to_char(var, 'yyyymmdd')
          OR T3.CLEAR_DT IS NULL)
     AND T2.SK_PROD IS NOT NULL
   UNION SELECT to_char(var, 'yyyymmdd') AS START_DT,
                to_char(var, 'yyyymmdd') AS END_DT,
                sk_prod AS prod,
                NVL(fund_brief_name, fund_name) FUND_NAME
   FROM T02_PROD_BASICINFO
   WHERE FUND_CODE='222003' ),
     TEMP_BOND AS
  (SELECT DISTINCT T0.PROD SK_F_PROD,
                   T0.FUND_NAME,
                   H.SK_F_BMPK_ID, --BI.SK_PRIMARY_KEY,
 H.BOND_NAME,
 BI.BOND_CODE,
 IC.INST_NAME,
 T0.START_DT,
 T0.END_DT
   FROM TEMP0 T0
   LEFT JOIN T09_HOLD_BOND H ON T0.PROD = H.SK_F_PROD
   LEFT JOIN T02_BONDMKTINFO BI ON H.SK_F_BMPK_ID = BI.SK_PRIMARY_KEY
   LEFT JOIN T02_BONDDT BT ON BI.SK_F_BOND = BT.SK_BOND
   LEFT JOIN
     (SELECT *
      FROM T02_CO_INDUSTRY_RELA
      WHERE INST_MODE = '044'
        AND LENGTH(INST_CODE) = 2) R ON BT.SK_F_COMPANY = R.SK_F_COMPANY
   LEFT JOIN T02_INDUSTRY_CLS IC ON R.INST_CODE = IC.INST_CODE
   AND R.INST_MODE = IC.INST_MODE
   WHERE H.POSITION_DT >= T0.START_DT
     AND H.POSITION_DT <= T0.END_DT ),
     temp9 AS
  (SELECT *
   FROM
     (SELECT T.sk_f_prod,
             T.FUND_BRIEF_NAME,--基金名称,
 T.NAME,--股票名称,
 nvl(sum(t.ZYK), 0) AS ZYK, ----总体盈亏
 row_number() OVER (PARTITION BY T.sk_f_prod
                    ORDER BY nvl(sum(t.ZYK), 0) DESC) rn
      FROM
        (SELECT DISTINCT tb.sk_f_prod AS sk_f_prod,
                         TB.FUND_NAME AS FUND_BRIEF_NAME,--基金名称,
 TB.BOND_NAME AS NAME,--股票名称,
 xx.TZSY+ xx.LXSR+ xx.GYJZBD AS ZYK ----总体盈亏
 /* row_number() over (partition by tb.sk_f_prod order by  (xx.TZSY+

     xx.LXSR+

     xx.GYJZBD) desc ) rn */
         FROM TEMP_BOND TB
         LEFT JOIN
           (SELECT DISTINCT t.*
            FROM t02_bond_code_relationship t
            WHERE status in (1,
                             '01')) a ON tb.SK_F_BMPK_ID=a.SK_F_BMPK_ID
         LEFT JOIN
           (SELECT x.sk_f_prod,
                   x.secu_inner_code,
                   sum(CASE
                           WHEN LENDING_DIRECTION ='JD_D'
                                AND x.subj_code like '6111%'
                                AND x.BUSS_INSTRUCTION not like '%公允价值变动损益%' THEN LOCAL_CURRENCY_AMT
                           ELSE 0
                       END) - sum(CASE
                                      WHEN LENDING_DIRECTION ='JD_J'
                                           AND x.subj_code like '6111%'
                                           AND x.BUSS_INSTRUCTION not like '%公允价值变动损益%' THEN LOCAL_CURRENCY_AMT
                                      ELSE 0
                                  END) AS TZSY, ---投资收益
 sum(CASE
         WHEN LENDING_DIRECTION ='JD_D'
              AND x.subj_code like '6011%' THEN LOCAL_CURRENCY_AMT
         ELSE 0
     END) - sum(CASE
                    WHEN LENDING_DIRECTION ='JD_J'
                         AND x.subj_code like '6011%' THEN LOCAL_CURRENCY_AMT
                    ELSE 0
                END) AS LXSR,--利息收入
 sum(CASE
         WHEN LENDING_DIRECTION ='JD_D'
              AND x.subj_code like '6101%'
              AND x.BUSS_INSTRUCTION like '%帐面调整%' THEN LOCAL_CURRENCY_AMT
         ELSE 0
     END) - sum(CASE
                    WHEN LENDING_DIRECTION ='JD_J'
                         AND x.subj_code like '6101%'
                         AND x.BUSS_INSTRUCTION like '%帐面调整%' THEN LOCAL_CURRENCY_AMT
                    ELSE 0
                END) AS GYJZBD--公允价值变动

            FROM T10_LOSS_PROFIT_CHG_DETAIL x,
                 temp0 a0
            WHERE x.sk_f_prod=a0.PROD
              AND x.BUSS_DT<=a0.END_DT
              AND x.BUSS_DT>=a0.START_DT
              AND x.BUSS_DT<=20201020
            GROUP BY x.sk_f_prod,
                     x.secu_inner_code) xx ON tb.sk_f_prod=xx.sk_f_prod
         AND xx.secu_inner_code=substr(a.subj_code, -6)
         UNION ALL SELECT DISTINCT tb.sk_f_prod AS sk_f_prod,
                                   TB.FUND_NAME AS FUND_BRIEF_NAME,--基金名称,
 TB.BOND_NAME AS NAME,--股票名称,
 xx.TZSY+ xx.LXSR+ xx.GYJZBD AS ZYK ----总体盈亏
 /*row_number() over (partition by tb.sk_f_prod order by  (xx.TZSY+

     xx.LXSR+

     xx.GYJZBD) desc ) rn */
         FROM TEMP_BOND TB /*LEFT JOIN (select distinct t.* from t02_bond_code_relationship t where status in (1,'01')) a

on tb.SK_F_BMPK_ID=a.SK_F_BMPK_ID */
         LEFT JOIN
           (SELECT x.sk_f_prod,
                   nvl(x.sk_f_secu, CASE
                                        WHEN x.subj_code like '6101%'
                                             AND x.BUSS_INSTRUCTION like '%证券库存估值%' THEN 'BMKT'||DECODE(SUBSTR(x.BUSS_INSTRUCTION, INSTR(x.BUSS_INSTRUCTION, ' ', 1, 1)+1, INSTR(x.BUSS_INSTRUCTION, '_', 1, 1)-INSTR(x.BUSS_INSTRUCTION, ' ', 1, 1)-1), 'SH', '001', 'SZ', '002', 'BI', '004') ||SUBSTR(x.BUSS_INSTRUCTION, INSTR(x.BUSS_INSTRUCTION, '[', 1, 3)+1, INSTR(x.BUSS_INSTRUCTION, ' ', 1, 1)-INSTR(x.BUSS_INSTRUCTION, '[', 1, 3)-1)
                                    END) sk_f_secu,
                   sum(CASE
                           WHEN LENDING_DIRECTION ='JD_D'
                                AND x.subj_code like '6111%'
                                AND x.BUSS_INSTRUCTION not like '%公允价值变动损益%' THEN LOCAL_CURRENCY_AMT
                           ELSE 0
                       END) - sum(CASE
                                      WHEN LENDING_DIRECTION ='JD_J'
                                           AND x.subj_code like '6111%'
                                           AND x.BUSS_INSTRUCTION not like '%公允价值变动损益%' THEN LOCAL_CURRENCY_AMT
                                      ELSE 0
                                  END) AS TZSY, ---投资收益
 sum(CASE
         WHEN LENDING_DIRECTION ='JD_D'
              AND x.subj_code like '6011%' THEN LOCAL_CURRENCY_AMT
         ELSE 0
     END) - sum(CASE
                    WHEN LENDING_DIRECTION ='JD_J'
                         AND x.subj_code like '6011%' THEN LOCAL_CURRENCY_AMT
                    ELSE 0
                END) AS LXSR,--利息收入
 sum(CASE
         WHEN LENDING_DIRECTION ='JD_D'
              AND x.subj_code like '6101%'
              AND x.BUSS_INSTRUCTION like '%证券库存估值%' THEN LOCAL_CURRENCY_AMT
         ELSE 0
     END) - sum(CASE
                    WHEN LENDING_DIRECTION ='JD_J'
                         AND x.subj_code like '6101%'
                         AND x.BUSS_INSTRUCTION like '%证券库存估值%' THEN LOCAL_CURRENCY_AMT
                    ELSE 0
                END) AS GYJZBD--公允价值变动

            FROM T10_LOSS_PROFIT_CHG_DETAIL x,
                 temp0 a0
            WHERE x.sk_f_prod=a0.PROD
              AND x.BUSS_DT<=a0.END_DT
              AND x.BUSS_DT>=a0.START_DT
              AND BUSS_INSTRUCTION not like '%结转%'
              AND x.BUSS_DT>20201020
            GROUP BY x.sk_f_prod,
                     nvl(x.sk_f_secu, CASE
                                          WHEN x.subj_code like '6101%'
                                               AND x.BUSS_INSTRUCTION like '%证券库存估值%' THEN 'BMKT'||DECODE(SUBSTR(x.BUSS_INSTRUCTION, INSTR(x.BUSS_INSTRUCTION, ' ', 1, 1)+1, INSTR(x.BUSS_INSTRUCTION, '_', 1, 1)-INSTR(x.BUSS_INSTRUCTION, ' ', 1, 1)-1), 'SH', '001', 'SZ', '002', 'BI', '004') ||SUBSTR(x.BUSS_INSTRUCTION, INSTR(x.BUSS_INSTRUCTION, '[', 1, 3)+1, INSTR(x.BUSS_INSTRUCTION, ' ', 1, 1)-INSTR(x.BUSS_INSTRUCTION, '[', 1, 3)-1)
                                      END)) xx ON tb.sk_f_prod=xx.sk_f_prod
         AND tb.SK_F_BMPK_ID=xx.sk_f_secu) T
      GROUP BY T.sk_f_prod,
               T.FUND_BRIEF_NAME,--基金名称,
 T.NAME--股票名称,
 )
   WHERE rn <=5) --select * from temp9
 ,
     TEMP11 AS
  (SELECT T9.SK_F_PROD,
          T9.NAME AS BOND_NAME,
          T9.ZYK,
          t9.RN
   FROM TEMP9 T9
   WHERE T9.ZYK > 0 )
SELECT *
FROM
  (SELECT T0.FUND_NAME,
          T1.BOND_NAME NAME1,
          T1.ZYK YK1,
          T2.BOND_NAME NAME2,
          T2.ZYK YK2,
          T3.BOND_NAME NAME3,
          T3.ZYK YK3,
          T4.BOND_NAME NAME4,
          T4.ZYK YK4,
          T5.BOND_NAME NAME5,
          T5.ZYK YK5,
          CASE
              WHEN (T1.ZYK IS NULL
                    AND T2.ZYK IS NULL
                    AND T3.ZYK IS NULL
                    AND T4.ZYK IS NULL
                    AND T5.ZYK IS NULL) THEN NULL
              ELSE NVL(T1.ZYK, 0) + NVL(T2.ZYK, 0) + NVL(T3.ZYK, 0) + NVL(T4.ZYK, 0) + NVL(T5.ZYK, 0)
          END YK_HZ
   FROM TEMP0 T0
   LEFT JOIN
     (SELECT SK_F_PROD,
             BOND_NAME,
             ZYK
      FROM TEMP11
      WHERE RN = 1) T1 ON T0.PROD = T1.SK_F_PROD
   LEFT JOIN
     (SELECT SK_F_PROD,
             BOND_NAME,
             ZYK
      FROM TEMP11
      WHERE RN = 2) T2 ON /*T1.SK_F_PROD*/ T0.PROD = T2.SK_F_PROD
   LEFT JOIN
     (SELECT SK_F_PROD,
             BOND_NAME,
             ZYK
      FROM TEMP11
      WHERE RN = 3) T3 ON /*T1.SK_F_PROD*/ T0.PROD = T3.SK_F_PROD
   LEFT JOIN
     (SELECT SK_F_PROD,
             BOND_NAME,
             ZYK
      FROM TEMP11
      WHERE RN = 4) T4 ON /*T1.SK_F_PROD*/ T0.PROD = T4.SK_F_PROD
   LEFT JOIN
     (SELECT SK_F_PROD,
             BOND_NAME,
             ZYK
      FROM TEMP11
      WHERE RN = 5) T5 ON /*T1.SK_F_PROD*/ T0.PROD = T5.SK_F_PROD
   ORDER BY T0.FUND_NAME)
WHERE YK1 IS NOT NULL

"""
    print(clean_comment(sql))
    print(get_tablename(sql))


