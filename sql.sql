select * from(
) where SOURCE_VALUE<>TARGET_VALUE

--产品估值凭证表估值增值与损益表中收益一致
select * from(

SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                    1              AS CNT
                      FROM  (
                       SELECT a.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL a
                         LEFT JOIN c02_prod_code_sum b ON a.sk_f_prod=b.sk_f_prod AND b.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE='GYBD'  
                       AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN 20200101 AND 20210804
                        AND SECU_VAR IN ('GP','ZQ') AND PROD_NAME NOT LIKE '%FOF%'
                      GROUP BY  a.SK_F_PROD,VOUCHER_DT )A
                      left join (   
                      SELECT SUM(DAILY_VALUATION) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_VALUATION_VOUCHER 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
					   
					   ) where SOURCE_VALUE<>TARGET_VALUE

--产品估值凭证表红利收入与损益表中收益一致
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                    1              AS CNT
                      FROM  (
                       SELECT a.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL a
                       LEFT JOIN c02_prod_code_sum b ON a.sk_f_prod=b.sk_f_prod AND b.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE='TZSY_HLSR' 
                       AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN 20200101 AND 20210804
                        AND SECU_VAR IN ('GP','ZQ')AND PROD_NAME NOT LIKE '%FOF%'
                      GROUP BY  a.SK_F_PROD,VOUCHER_DT )A
                      left join (   
                      SELECT SUM(DIVIDEND_INCOME) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_VALUATION_VOUCHER 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
--产品估值凭证表票息收入与损益表中收益一致
select * from (
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                    1              AS CNT
                      FROM  (
                       SELECT a.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL a
                         LEFT JOIN c02_prod_code_sum b ON a.sk_f_prod=b.sk_f_prod AND b.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE LIKE 'LXSR%'  
                       AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN 20200101 AND 20210804
                        AND SECU_VAR IN ('GP','ZQ') AND PROD_NAME NOT LIKE '%FOF%'
                      GROUP BY  a.SK_F_PROD,VOUCHER_DT )A
                      left join (   
                      SELECT SUM(COUPON_INCOME) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_VALUATION_VOUCHER 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
					   ) where SOURCE_VALUE<>TARGET_VALUE
--产品估值凭证表数据量与产品持仓汇总表数据量一致
SELECT A.POSITION_DT AS BUSS_DATE,
       A.SK_F_PROD AS SK_F_PROD,
       NVL(A.SOURCE_VALUE, 0) AS SOURCE_VALUE,
       NVL(B.TARGET_VALUE, 0) AS TARGET_VALUE,
       1 AS CNT
  FROM (SELECT SK_F_PROD, POSITION_DT, COUNT(*) SOURCE_VALUE FROM 
 ( SELECT  DISTINCT SK_F_PROD, POSITION_DT,sk_f_secu
          FROM C12_PROD_HOLD_SUMMARY
         WHERE POSITION_DT BETWEEN 20200101 AND 20210804
           and ACCOUNT_PROJECT_CODE = 'ZQTZ_CB'
           and secu_var in ('股票品种', '债券品种') 
          AND LOCC_MKT_VAL>0)
         GROUP BY SK_F_PROD, POSITION_DT) A

  left join (SELECT SK_F_PROD, TRADE_DT, COUNT(*) TARGET_VALUE
               FROM SDI_PROD_VALUATION_VOUCHER
              WHERE TRADE_DT BETWEEN 20200101 AND 20210804
              AND LOCC_POSI_MKT_VAL>0
              GROUP BY SK_F_PROD, TRADE_DT) B
    ON A.SK_F_PROD = B.SK_F_PROD
   AND A.POSITION_DT = B.TRADE_DT
--产品估值凭证表资本利得与损益表中收益一致
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                    1              AS CNT
                      FROM  (
                       SELECT a.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL a
                        LEFT JOIN c02_prod_code_sum b ON a.sk_f_prod=b.sk_f_prod AND b.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE='TZSY_CJSR'  
                       AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN 20200101 AND 20210804
                       AND secu_var IN ('GP','ZQ')AND PROD_NAME NOT LIKE '%FOF%'
                      GROUP BY  a.SK_F_PROD,VOUCHER_DT )A
                      left join (   
                      SELECT SUM(CAPITAL_GAIN) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_VALUATION_VOUCHER 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
--产品行情_货币型资产净值条数验证
select * from (
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM
(SELECT COUNT(COUNT(*)) AS SOURCE_VALUE
FROM (SELECT A.D_ASTSTAT AS D_BIZ,  A.C_PORT_CODE AS C_PORT_CODE,  C_KEY_CODE, A.N_PORT_MV * A.N_WAY AS N_HLDMKV_LOCL
      FROM (SELECT T1.D_ASTSTAT,T1.C_PORT_CODE, T1.C_KEY_CODE, CASE WHEN T1.N_WAY = 0 THEN  1 ELSE   T1.N_WAY  END AS N_WAY,  T1.N_PORT_MV
	        FROM S20_T_R_FR_ASTSTAT T1
			FULL  JOIN S20_T_R_FR_ASTSTAT AST
			ON T1.D_ASTSTAT = AST.D_ASTSTAT
			AND T1.C_PORT_CODE = AST.C_PORT_CODE
			AND AST.C_NAV_TYPE = 'CHECK'
			AND AST.C_KEY_CODE = 'ZZR'
			WHERE T1.D_ASTSTAT >=  TO_DATE(20200101, 'yyyymmdd')
			AND T1.D_ASTSTAT <= TO_DATE(20210804, 'yyyymmdd')
			AND T1.C_NAV_TYPE LIKE 'TOTAL%'
			AND SUBSTR(T1.C_KM_CODE, 1, 1) >= 6
			UNION ALL
			SELECT T2.D_ASTSTAT,T2.C_PORT_CODE,T2.C_KEY_CODE,CASE  WHEN T2.N_WAY = 0 THEN  1  ELSE T2.N_WAY END AS N_WAY, T2.N_PORT_MV
			FROM S20_T_R_FR_ASTSTAT_SUM T2
			FULL JOIN S20_T_R_FR_ASTSTAT AST
			ON T2.D_ASTSTAT = AST.D_ASTSTAT
			AND T2.C_PORT_CODE = AST.C_PORT_CODE
			AND AST.C_NAV_TYPE = 'CHECK'
			AND AST.C_KEY_CODE = 'ZZR'
			WHERE T2.D_ASTSTAT >= TO_DATE(20200101, 'yyyymmdd')
			AND T2.D_ASTSTAT <= TO_DATE(20210804, 'yyyymmdd')
			AND T2.C_NAV_TYPE LIKE 'TOTAL%'
			AND SUBSTR(T2.C_KM_CODE, 1, 1) >= 6) A) T1,
			(SELECT FUND_CODE, FUND_NATURE
			 FROM T02_PROD_BASICINFO
			 WHERE NET_WP_WAY = '0') T2
			WHERE NVL(T2.FUND_NATURE, ' ') IN ('5', '16')
			AND T2.FUND_CODE = T1.C_PORT_CODE
			AND T1.C_KEY_CODE = 'ZCJZ'
			AND T1.N_HLDMKV_LOCL <> 0
			AND T1.C_PORT_CODE IN
			(SELECT SUBSTR(SK_F_PARE_PROD, 5, 6)
             FROM T01_CLASS_PROD_INFO
			 WHERE CLASS_LEVEL_TYPE = '02')
			 GROUP BY T1.D_BIZ, T1.C_PORT_CODE) A,
(SELECT COUNT(*) AS TARGET_VALUE
FROM T02_PROD_QUOTATION_CURR A, T01_CLASS_PROD_INFO B
WHERE A.SK_F_PROD = B.SK_F_CLASS_PROD
AND A.BUSS_DT >= 20200101
AND A.BUSS_DT <= 20210804
AND A.FUND_ASS_NET_VAL <> 0
AND A.SYSTEM_SOURCE = 'S20'
) B
)where SOURCE_VALUE<>TARGET_VALUE
--产品行情表母基金净值与持仓汇总表一致性
select * from (
SELECT 
A.POSITION_DT AS BUSS_DATE,
A.SK_F_PROD AS SK_F_PROD,
NVL(SOURCE_VALUE,0) SOURCE_VALUE,
NVL(TARGET_VALUE,0) TARGET_VALUE,
1   AS CNT
FROM 
 (SELECT POSITION_DT,a.SK_F_PROD,sum(case when subj_cLASS='负债' THEN -LOCC_MKT_VAL 
 ELSE LOCC_MKT_VAL END ) SOURCE_VALUE
 FROM C12_PROD_HOLD_SUMMARY a
  JOIN c02_prod_code_sum b ON a.sk_f_prod=b.sk_f_prod AND b.sk_f_prod_source='01'
 WHERE  POSITION_DT BETWEEN 20200101 AND 20210804 
  AND (NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT)>=20210804 OR  NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT) IS NULL)
 GROUP BY  POSITION_DT,a.SK_F_PROD) A
 LEFT JOIN
 (SELECT SK_F_PROD,TRADE_DT ,FUND_ASS_NET_VAL AS TARGET_VALUE FROM (SELECT SK_F_PROD,TRADE_DT ,FUND_ASS_NET_VAL  
 FROM  T02_PROD_QUOTATION_T 
 WHERE   TRADE_DT BETWEEN 20200101 AND 20210804
 UNION 
 SELECT SK_F_PROD,BUSS_DT AS TRADE_DT,FUND_ASS_NET_VAL FROM  T02_PROD_QUOTATION_CURR_T 
 WHERE   BUSS_DT BETWEEN 20200101 AND 20210804))B
 ON A.SK_F_PROD=B.SK_F_PROD AND A.POSITION_DT=B.TRADE_DT
 )where SOURCE_VALUE<>TARGET_VALUE
 
--产品行情表数据缺失
SELECT    TO_NUMBER(TO_CHAR(A.D_BIZ,'yyyymmdd'))     AS BUSS_DATE,
A.SK_PROD    AS SK_F_PROD,
NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
1              AS CNT
FROM  (
select D_BIZ,SK_PROD,count(*) SOURCE_VALUE from (
select a.D_BIZ,
c.SK_PROD,
sum(case
when  C_SUBJ_CODE='831'AND 
instr(a.C_KEY_NAME, '资产合计') > 0 THEN 
nvl(a.N_HLDMKV_LOCL, 0)
else
 0
end) ZCHJ,
  SUM(CASE WHEN C_SUBJ_CODE='811'THEN N_HLDAMT ELSE 0 END ) sszb
from S20_VF_REPORT_VAL  a 
inner join T02_PROD_BASICINFO c
on a.C_PORT_CODE = c.FUND_CODE
where TO_CHAR(A.D_BIZ,'yyyymmdd') BETWEEN '20200101' AND '20210804'
group by a.D_BIZ,c.SK_PROD
)t
where t.ZCHJ>0 AND t.sszb>0
group by D_BIZ,SK_PROD )a
left join (   SELECT SK_F_PROD,TRADE_DT,COUNT(*) TARGET_VALUE
FROM  SDI_PROD_QUOTE_D 
WHERE TRADE_DT BETWEEN 20200101 AND 20210804
GROUP BY  SK_F_PROD,TRADE_DT) B
ON A.SK_PROD=B.SK_F_PROD 
AND TO_NUMBER(TO_CHAR(A.D_BIZ,'yyyymmdd'))=B.TRADE_DT
--产品行情日频数据表的非清盘产品行情不连续
WITH TMP AS(
SELECT A.*,B.SK_F_PROD AS SK_F_PROD1
FROM ( SELECT T2.CALENDAR_DT AS TRADE_DT,T1.SK_F_PROD,T1.SK_F_PROD_SOURCE
       FROM C02_PROD_CODE_SUM T1,
            T00_TRADEDATE_EXTEND T2
       WHERE  T2.MKT_CODE='001'and t1.SK_F_PROD_SOURCE='01' 
       AND T2.CALENDAR_DT BETWEEN 20200101 AND 20210804
       AND T1.SK_F_PROD_SOURCE='01' AND SK_F_FUND_COMPANY='CO80000238'
       AND PROD_NAME NOT LIKE '%FOF%' AND PROD_NAME NOT LIKE '%QDII%' AND PROD_CODE NOT IN ('221165','220412','221156')
       AND T2.CALENDAR_DT>=t1.PROD_FOUND_DT AND  T2.CALENDAR_DT<=NVL(NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT),'29990101')
)A
LEFT JOIN SDI_PROD_QUOTE_D B
ON A.TRADE_DT=B.TRADE_DT
AND A.SK_F_PROD=B.SK_F_PROD
)
SELECT a.TRADE_DT AS BUSS_DATE,
       a.SK_F_PROD||'|'||a.TRADE_DT   AS SK_F_PROD,
       A.SK_F_PROD1,
       NULL AS SOURCE_VALUE,
       NULL AS TARGET_VALUE,
       1 AS CNT,
       CONCAT('SK_F_PROD=',a.SK_F_PROD) AS REMARK
FROM TMP A 
WHERE A.SK_F_PROD1 IS NULL

 UNION ALL
SELECT 1 AS BUSS_DATE,
       NULL AS SK_F_PROD,
        NULL SK_F_PROD1,
       '1' AS SOURCE_VALUE,
       '1' AS TARGET_VALUE,
       count(*) AS CNT,
       NULL as REMARKS
FROM TMP A
WHERE A.SK_F_PROD1 IS NOT NULL 
--产品行情日频数据中估值增值与损益表中收益一致
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                   NVL(A.SOURCE_VALUE,0)- NVL(B.TARGET_VALUE,0) AS ce,
                    1              AS CNT
                      FROM  (
                       SELECT t1.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL t1
                        JOIN c02_prod_code_sum t2 ON t1.sk_f_prod=t2.sk_f_prod AND t2.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE='GYBD'  AND PROD_FOUND_DT<=20210804
                       AND NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT)>=20200101
                      AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN  20200101 AND 20210804
                       AND SK_F_FUND_COMPANY='CO80000238'AND PROD_NAME NOT LIKE '%FOF%' 
                       AND PROD_NAME NOT LIKE '%QDII%' AND t1.SK_F_PROD NOT IN ('PD02221165','PD02220412')
                      GROUP BY  t1.SK_F_PROD,VOUCHER_DT)a
                      left join (   
                      SELECT SUM(DAILY_VALUATION) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_QUOTE_D 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                        AND SK_F_PROD_SOURCE='01'
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
--产品行情日频数据中红利收入与损益表中收益一致
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                   NVL(A.SOURCE_VALUE,0)- NVL(B.TARGET_VALUE,0) AS ce,
                    1              AS CNT
                      FROM  (
                       SELECT t1.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL t1
                        JOIN c02_prod_code_sum t2 ON t1.sk_f_prod=t2.sk_f_prod AND t2.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE='TZSY_HLSR'  AND PROD_FOUND_DT<=20210804
                       AND NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT)>=20200101
                      AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN  20200101 AND 20210804
                       AND SK_F_FUND_COMPANY='CO80000238'AND PROD_NAME NOT LIKE '%FOF%' 
                       AND PROD_NAME NOT LIKE '%QDII%' AND t1.SK_F_PROD NOT IN ('PD02221165','PD02220412')
                      GROUP BY  t1.SK_F_PROD,VOUCHER_DT)a
                      left join (   
                      SELECT SUM(DIVIDEND_INCOME) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_QUOTE_D 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                        AND SK_F_PROD_SOURCE='01'
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
--产品行情日频数据中每日数据量与产品行情表一致
 SELECT    A.TRADE_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                    1              AS CNT
                      FROM  (SELECT SK_F_PROD,TRADE_DT ,COUNT(*) AS SOURCE_VALUE FROM 
                      (SELECT SK_F_PROD,TRADE_DT ,FUND_ASS_NET_VAL  
                 FROM  C02_PROD_QUOTATION a
                   JOIN t00_tradedate_extend b ON b.CALENDAR_DT=a.trade_dt 
                      AND b.MKT_CODE='001' AND IF_TRADE_DT='是'
                 WHERE   TRADE_DT BETWEEN 20200101 AND 20210804
                 AND SK_F_PROD_SOURCE='01'
                 UNION 
                 SELECT SK_F_PROD,BUSS_DT AS TRADE_DT,FUND_ASS_NET_VAL FROM  C02_PROD_QUOTATION_CURR a
                  JOIN t00_tradedate_extend b ON b.CALENDAR_DT=a.BUSS_DT 
                      AND b.MKT_CODE='001' AND IF_TRADE_DT='是'
                   WHERE  BUSS_DT BETWEEN 20200101 AND 20210804
                      AND SK_F_PROD_SOURCE='01')GROUP BY SK_F_PROD,TRADE_DT)A

                      left join (   SELECT SK_F_PROD,TRADE_DT,COUNT(*) TARGET_VALUE
                      FROM  SDI_PROD_QUOTE_D a
                      JOIN t00_tradedate_extend b ON b.CALENDAR_DT=a.trade_dt 
                      AND b.MKT_CODE='001' AND IF_TRADE_DT='是'
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                      GROUP BY  SK_F_PROD,TRADE_DT) B
ON A.SK_F_PROD=B.SK_F_PROD AND A.TRADE_DT=B.TRADE_DT
--产品行情日频数据中票息收入与损益表中收益一致
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                    1              AS CNT
                      FROM  (
                       SELECT t1.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL t1
                        JOIN c02_prod_code_sum t2 ON t1.sk_f_prod=t2.sk_f_prod AND t2.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE LIKE '%LXSR%'  AND PROD_FOUND_DT<=20210804
                       AND NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT)>=20200101
                      AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN  20200101 AND 20210804
                       AND SK_F_FUND_COMPANY='CO80000238'AND PROD_NAME NOT LIKE '%FOF%' 
                       AND PROD_NAME NOT LIKE '%QDII%' AND t1.SK_F_PROD NOT IN ('PD02221165','PD02220412')
                      GROUP BY  t1.SK_F_PROD,VOUCHER_DT)a
                      left join (   
                      SELECT SUM(COUPON_INCOME) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_QUOTE_D 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                        AND SK_F_PROD_SOURCE='01'
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
--产品行情日频数据中资本利得与损益表中收益一致
SELECT    A.VOUCHER_DT     AS BUSS_DATE,
                    A.SK_F_PROD    AS SK_F_PROD,
                   NVL(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
                   NVL(B.TARGET_VALUE,0) AS TARGET_VALUE,
                   NVL(A.SOURCE_VALUE,0)- NVL(B.TARGET_VALUE,0) AS ce,
                    1              AS CNT
                      FROM  (
                       SELECT t1.SK_F_PROD,VOUCHER_DT,SUM(LOCAL_CURRENCY_AMT) SOURCE_VALUE
                        FROM T10_LOSS_PROFIT_CHG_DETAIL t1
                        JOIN c02_prod_code_sum t2 ON t1.sk_f_prod=t2.sk_f_prod AND t2.SK_F_PROD_SOURCE='01'
                       WHERE ACCOUNT_PROJECT_CODE='TZSY_CJSR'  AND PROD_FOUND_DT<=20210804
                       AND NVL(PROD_EXPIRE_DT,PROD_CLEAR_DT)>=20200101
                      AND   BUSS_INSTRUCTION  not like '%结转%'
                       AND REGEXP_LIKE(SUBJ_CODE, '^6[0123].*') AND LENDING_DIRECTION = 'JD_D' 
                       AND  VOUCHER_DT BETWEEN  20200101 AND 20210804
                       AND SK_F_FUND_COMPANY='CO80000238'AND PROD_NAME NOT LIKE '%FOF%' 
                       AND PROD_NAME NOT LIKE '%QDII%' AND t1.SK_F_PROD NOT IN ('PD02221165','PD02220412')
                      GROUP BY  t1.SK_F_PROD,VOUCHER_DT)a
                      left join (   
                      SELECT SUM(CAPITAL_GAIN) AS TARGET_VALUE,
                      SK_F_PROD,TRADE_DT
                      FROM  SDI_PROD_QUOTE_D 
                       WHERE TRADE_DT BETWEEN 20200101 AND 20210804
                        AND SK_F_PROD_SOURCE='01'
                      GROUP BY  SK_F_PROD,TRADE_DT) B
                       ON A.SK_F_PROD=B.SK_F_PROD 
                       AND A.VOUCHER_DT=B.TRADE_DT
--存款成交表验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_D_AC_TRADE_DEP A
LEFT JOIN S20_T_P_SV_SEC_BASE C
ON A.C_SEC_CODE = C.C_SEC_CODE
WHERE A.N_CHECK_STATE = 1
AND A.C_TD_TYPE = 'CKTZ'
AND C.N_CHECK_STATE = 1
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) <= 20210804
) A
, (
SELECT  count(*) as TARGET_VALUE
from T05_DEPOSITS_SERIAL A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
) B
--存款持仓表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM (
SELECT   C_PORT_CODE,C_KM_CODE,D_ASTSTAT
FROM S20_T_R_FR_ASTSTAT A
WHERE A.C_NAV_TYPE IN ('CACH_SEC', 'CACH')
AND A.C_KM_CODE LIKE '1002%'
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804) A
FULL JOIN 
(SELECT C_PORT_CODE,C_KM_CODE,D_ASTSTAT
FROM S20_T_R_FR_ASTSTAT
  where C_DAI_CODE IN ('YSLX_ZJ', 'YSLX_ZQ')
    and C_KM_CODE like '1204%'
    and (instr(C_KM_CODE,'CNY') > 0 or instr(C_KM_CODE,'CK') > 0)
    AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
    AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804
)B
ON  A.C_PORT_CODE = B.C_PORT_CODE
AND A.C_KM_CODE = B.C_KM_CODE
AND A.D_ASTSTAT = B.D_ASTSTAT
) A
, (
SELECT  count(*) as TARGET_VALUE
from T09_HOLD_DEPOSIT
WHERE SYSTEM_SOURCE = 'S20'
AND POSITION_DT >= 20200101
AND POSITION_DT <= 20210804
) B
非货币型基金复权单位净值不能为0或空
SELECT A.TRADE_DT AS BUSS_DATE,
                  SK_F_PROD || '|' || TRADE_DT   AS SK_F_PROD,
                  NULL AS SOURCE_VALUE,
                  NULL AS TARGET_VALUE,
                  1 AS CNT,
                  concat('NAV_ADJUSTED_DEF||NAV_ADJUSTED_DEF = ', NAV_ADJUSTED_DEF||'|'||NAV_ADJUSTED_DEF) as REMARKS
                    from (select *
                         from SDI_PROD_QUOTE_D 
                          WHERE IS_CURR='非货币型'AND NVL(NAV_ADJUSTED_DEF,0)=0
                         and TRADE_DT between 20200101 AND 20210804) A
               UNION ALL
           SELECT 1 AS BUSS_DATE,
                  NULL AS SK_F_PROD,
                  '1' AS SOURCE_VALUE,
                  '1' AS TARGET_VALUE,
                  FINE_COUNT AS CNT,
                  NULL as REMARKS
               from (select (total_count - issue_count) as FINE_COUNT
                     FROM   (select count(*) total_count
                     from SDI_PROD_QUOTE_D
                     where TRADE_DT between 20200101 AND 20210804
                     ) m, 
                     (select count(*) issue_count
                         from SDI_PROD_QUOTE_D a
                           WHERE IS_CURR='非货币型'AND NVL(NAV_ADJUSTED_DEF,0)=0
                         and TRADE_DT between 20200101 AND 20210804) n
                       ) B
股票成交信息表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT COUNT(*) AS SOURCE_VALUE
FROM  (
 SELECT A.C_PORT_CODE
  FROM S20_T_D_AC_TRADE_IVT A
  WHERE A.N_CHECK_STATE = 1 AND A.C_TD_TYPE = 'GPJY'
  and A.D_TRADE >= to_date(20200101,'yyyymmdd')
  and A.D_TRADE <= to_date(20210804,'yyyymmdd')
  UNION ALL
  --送股、配股
  SELECT A.C_PORT_CODE
  FROM S20_T_D_AC_TRADE_DS A
  WHERE A.N_CHECK_STATE = 1 AND A.C_DT_CODE IN ('ZQSP_SG', 'ZQSP_PG')
  and A.D_TRADE >= to_date(20200101,'yyyymmdd')
  and A.D_TRADE <= to_date(20210804,'yyyymmdd')
  UNION ALL
  --上市流通
  SELECT A.C_PORT_CODE
  FROM S20_T_D_AC_TRADE_SL A
  WHERE A.N_CHECK_STATE = 1 AND A.C_SEC_VAR_CODE LIKE 'GP%'
  and A.D_TRADE >= to_date(20200101,'yyyymmdd')
  and A.D_TRADE <= to_date(20210804,'yyyymmdd')
  UNION ALL
  --新股
  SELECT A.C_PORT_CODE
   FROM S20_T_D_AC_TRADE_IPO A
       LEFT JOIN S20_T_P_SV_SEC_BASE C
          ON A.C_SEC_CODE = C.C_SEC_CODE
   WHERE A.N_CHECK_STATE = 1 AND C.C_SEC_VAR_CODE LIKE 'GP%' AND A.C_DT_CODE='XGSG_QR'
  and A.D_TRADE >= to_date(20200101,'yyyymmdd')
  and A.D_TRADE <= to_date(20210804,'yyyymmdd')) T2
 join  T02_PROD_BASICINFO T1  
 on T1.FUND_CODE = T2.C_PORT_CODE AND T1.NET_WP_WAY ='0'
WHERE (T1.PROD_TYPE <> '01' OR (T1.PROD_TYPE = '01' and T1.SYSTEM_SOURCE = 'S20'))
) A
, (
SELECT  count(*) as TARGET_VALUE
from T05_STOCK_TRANSACTION_INFO A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
) B
股票持仓市值总额数值验证

SELECT
    'S20' AS DATA_SOURCE,
    TRADE_DT AS BUSS_DATE, --如果没有业务日期就和LOG_DATE相等
    'T09_HOLD_STOCK' AS SOURCE_TABLE_NAME, --源表名
    'POSI_MKT_VAL' AS SOURCE_COLUMN_NAME, --源列名
    nvl(SOURCE_VALUE,0), --源数据值
    'T10_BALANCESHEET' AS TARGET_TABLE_NAME, --目标表名
    'STOCK_INVESTMENT_VAL' AS TARGET_COLUMN_NAME, --目标列名
    nvl(TARGET_VALUE,0), --目标数据值
    (CASE
        WHEN NVL(SOURCE_VALUE,0) = NVL(TARGET_VALUE,0) THEN '1'
        ELSE '2'
    END) AS STATUS,
    NULL AS REMARKS,
    '1' AS VERIFICATION_TOTAL_NUM,
    (CASE
        WHEN NVL(SOURCE_VALUE,0) = NVL(TARGET_VALUE,0) THEN '0'
        ELSE '1'
    END) AS ISSUE_NUM,
    SK_F_PROD AS SK_F_PROD,
    20200101 AS START_DT,
    20210804 AS END_DT
FROM (SELECT A.SK_F_PROD AS SK_F_PROD,
            A.TRADE_DT AS TRADE_DT,
			--TO_CHAR(SYSDATE,'YYYYMMDD') AS TRADE_DT,
            B.SOURCE_VALUE,
            --'LOCC_POSI_MKT_VAL' AS TARGET_COLUMN_NAME,
            A.TARGET_VALUE AS TARGET_VALUE
        FROM --源表明细
        (
SELECT A.POSITION_DT,
                    A.SK_F_PROD,
                    SUM(A.POSI_MKT_VAL) SOURCE_VALUE
               FROM T09_HOLD_STOCK A
              WHERE SYSTEM_SOURCE = 'S20'
                AND A.POSITION_DT >= 20200101
                AND A.POSITION_DT <= 20210804
              GROUP BY A.POSITION_DT, A.SK_F_PROD) B
        RIGHT JOIN
        --目标表明细
        (
SELECT SK_F_PROD, TRADE_DT, STOCK_INVESTMENT_VAL TARGET_VALUE
          FROM T10_BALANCESHEET
         WHERE SYSTEM_SOURCE = 'S20'
           AND TRADE_DT >= 20200101
           AND TRADE_DT <= 20210804) A
ON B.POSITION_DT = A.TRADE_DT
AND B.SK_F_PROD = A.SK_F_PROD
		)
股票基本信息表数据条数验证
select to_char(SYSDATE, 'YYYYMMDD') as BUSS_DATE,
       null as SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT,
       NULL AS REMARK
  from (select count(*) SOURCE_VALUE
          from (select A.secode,
                       ROW_NUMBER() OVER(PARTITION BY symbol ORDER BY LISTDATE DESC) RN
                  from S01_TQ_SK_BASICINFO A
                 where A.ISVALID = 1
                UNION ALL
                select B.secode,
                       ROW_NUMBER() OVER(PARTITION BY symbol ORDER BY LISTDATE DESC) RN
                  from S02_TQ_SK_HKBASICINFO B
                 where B.ISVALID = 1) A
         INNER JOIN (SELECT SECODE,
                           SENAME,
                           SESNAME,
                           COMPCODE,
                           ROW_NUMBER() OVER(PARTITION BY SECODE ORDER BY BEGINDATE DESC) RN
                      FROM S01_TQ_OA_STCODE
                     WHERE ISVALID = 1) B
            ON A.SECODE = B.SECODE
           AND B.RN = 1
         where A.rn = 1) A,
       (select count(*) TARGET_VALUE from SDI_STOCK) B
股票行情日频数据表与财汇源表数据条数验证
SELECT to_char(sysdate, 'yyyymmdd') AS BUSS_DATE,
       B.TRADE_DT AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT,
       CONCAT('TRADE_DT=', B.TRADE_DT) AS REMARK
  FROM (select B.CALENDAR_DT, count(*) as SOURCE_VALUE
          from (SELECT SECODE, EXCHANGE, SYMBOL, DELISTDATE, LISTDATE
                  FROM S01_TQ_SK_BASICINFO
                 where isvalid = 1
                --and listdate!='19000101'
                union all
                select SECODE, EXCHANGE, SYMBOL, DELISTDATE, LISTDATE
                  from (select SECODE,
                               EXCHANGE,
                               SYMBOL,
                               DELISTDATE,
                               LISTDATE,
                               row_number() over(partition by symbol, exchange order by secode desc) rn
                          from S02_TQ_SK_HKBASICINFO) t
                 where t.rn = 1) A
         INNER JOIN (SELECT SECODE,
                           SENAME,
                           ROW_NUMBER() OVER(PARTITION BY SECODE ORDER BY BEGINDATE DESC) as rn
                      FROM S01_TQ_OA_STCODE
                     WHERE ISVALID = 1) a1
            ON A.SECODE = a1.SECODE
           AND a1.rn = 1
          LEFT JOIN (SELECT ENUM_CODE, ENUM_NAME, SOURCE_ENU_VALUE
                      FROM T00_SINITEK_SOURCE_MAPPING
                     WHERE SINITEK_TABLE = 'XN_TABLES' -- 目标表
                       AND SINITEK_FIELD = 'MKT_CODE' -- 目标字段
                       AND SOURCE = 'S02' -- 数据来源
                       AND SOURCE_TABLE = 'S02_TABLES' -- 源表
                       AND SOURCE_FIELD = 'NEWFINCHINA_FIELD' -- 源字段
                    ) C
            ON C.SOURCE_ENU_VALUE = A. EXCHANGE
         INNER JOIN T00_TRADEDATE_EXTEND B
            ON B.MKT_CODE = NVL(C.ENUM_CODE, '000')
         WHERE A. SYMBOL NOT IN (--'00288',
                              --'01283',
                              '01337',
                              '03332'
                              --'688217',
                              --'688355',
                              --'688565',
                              --'300990',
                              --'605488',
                              --'300989',
                              --'605296',
                              --'688685',
                              --'300988',
                              --'001205',
                              --'688639'
                              )
           and B.CALENDAR_DT >= cast(A.LISTDATE as decimal(8, 0))
           AND (B.CALENDAR_DT <= cast(A.DELISTDATE as decimal(8, 0)) OR
               A.DELISTDATE = '19000101')
           AND B.CALENDAR_DT >= ${start_date}
           AND B.CALENDAR_DT <= ${end_date}
        
         GROUP BY B.CALENDAR_DT) A
  LEFT JOIN (SELECT TRADE_DT, COUNT(*) AS TARGET_VALUE
               FROM SDI_STOCK_QUOTE_D
              WHERE TRADE_DT BETWEEN ${end_date} AND ${end_date}
                and sk_f_stock not in (--'STOCK00300288',
                                       --'STOCK00301283',
                                       'STOCK00301337',
                                       'STOCK00303332'
                                       --'STOCK001688217',
                                       --'STOCK001688355',
                                      -- 'STOCK001688565',
                                       --'STOCK002300990',
                                       --'STOCK001605488',
                                       --'STOCK002300989',
                                       --'STOCK001605296',
                                       --'STOCK001688685',
                                       --'STOCK002300988',
                                       --'STOCK002001205',
                                       --'STOCK001688639'
                                       )
             -- 修改;沈仕海 2021.02.28 A.SYMBOL NOT IN ('00288','01283' ,'01337' ,'03332') 港股问题数据
             -- 修改:张超，股票基本信息表上市日期错误，科创版股票且没有行情数据。
              GROUP BY TRADE_DT) B
    ON A.CALENDAR_DT = CAST(B.TRADE_DT as decimal(8, 0))
股票行情日频数据从上市之后的每个交易日都有数据
SELECT to_char(sysdate, 'yyyymmdd') AS BUSS_DATE,
       a.sk_primary_key,
       A.sk_primary_key || '|' || A.CALENDAR_DT AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       NVL(B.TARGET_VALUE, 0) AS TARGET_VALUE,
       1 AS CNT,
       CONCAT((A.sk_primary_key ||'|'|| A.CALENDAR_DT||'='),
              (B.SK_F_STOCK || '|' || B.TRADE_DT)) AS REMARK
  from (SELECT count(*) AS SOURCE_VALUE, A.sk_primary_key , B.CALENDAR_DT
          FROM T02_STOCK A
          LEFT JOIN T00_TRADEDATE_EXTEND B
            ON A.MKT_CODE = B.MKT_CODE
         WHERE B.CALENDAR_DT >= LIST_DT
           AND B.CALENDAR_DT <= to_number(to_char(sysdate, 'yyyymmdd'))
           AND (B.CALENDAR_DT <= A.DELIST_DT OR A.DELIST_DT = 19000101)
           AND B.IF_TRADE_DT = '是'
           and A.list_dt != 19000101
           AND STOCK_NAME NOT LIKE '%股权%' AND  STOCK_TYPE_DETAIL NOT IN('EQN','SGQ')
           and sk_primary_key not in ('STOCK00300288',
                                'STOCK00301283',
                                'STOCK00301337',
                                'STOCK00303332',
                                'STOCK001688217',
                                'STOCK001688355',
                                'STOCK001688565',
                                'STOCK002300990',
                                'STOCK001605488',
                                'STOCK002300989',
                                'STOCK001605296',
                                'STOCK001688685',
                                'STOCK002300988',
                                'STOCK002001205')
              -- 修改;沈仕海 2021.02.28 A.SYMBOL NOT IN ('00288','01283' ,'01337' ,'03332') 港股问题数据
              -- 修改:张超，股票基本信息表上市日期错误，科创版股票且没有行情数据。
           AND B.CALENDAR_DT BETWEEN ${start_date} AND ${end_date}
         group by A.sk_primary_key, B.CALENDAR_DT
        
        ) A
  left join (SELECT count(*) AS TARGET_VALUE, SK_F_STOCK, TRADE_DT
               FROM SDI_STOCK_QUOTE_D
              WHERE trade_dt BETWEEN ${start_date} AND ${end_date}
              GROUP BY SK_F_STOCK, TRADE_DT) B
    ON A.sk_primary_key = B.SK_F_STOCK
   AND A.CALENDAR_DT = B.TRADE_DT
回购成交信息条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT COUNT(*) AS SOURCE_VALUE
FROM(
SELECT * FROM  
  T02_PROD_BASICINFO T1,
  (SELECT A.C_PORT_CODE,A.C_MKT_CODE,A.D_TRADE
   FROM S20_T_D_AC_TRADE_IVT A 
   LEFT JOIN S20_T_P_SV_SEC_BASE D
          ON A.C_SEC_CODE = D.C_SEC_CODE
   WHERE A.N_CHECK_STATE = 1 AND A.C_TD_TYPE in ('HGJY','HGJY_GP') AND D.N_CHECK_STATE = 1 
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')) T2
WHERE T1.FUND_CODE = T2.C_PORT_CODE AND T1.NET_WP_WAY ='0'
  AND T2.C_MKT_CODE IN ('XCFE','OOTC','COTC')
UNION ALL
SELECT *
FROM  T02_PROD_BASICINFO T1,
  (SELECT A.C_PORT_CODE,A.C_MKT_CODE,A.D_TRADE
   FROM S20_T_D_AC_TRADE_IVT A
   LEFT JOIN S20_T_P_SV_SEC_BASE D
          ON A.C_SEC_CODE = D.C_SEC_CODE
   WHERE A.N_CHECK_STATE = 1 AND A.C_TD_TYPE in ('HGJY','HGJY_GP') AND D.N_CHECK_STATE = 1 
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')) T2
WHERE T1.FUND_CODE = T2.C_PORT_CODE AND T1.NET_WP_WAY ='0'
  AND T2.C_MKT_CODE NOT IN ('XCFE','OOTC','COTC')
)
) A
, (
SELECT  count(*) as TARGET_VALUE
FROM(
SELECT SK_PRIMARY_KEY
from T05_EXCH_REPUR_TRAN_INFO A
 WHERE A.SYSTEM_SOURCE = 'S20'
 AND A.TRADE_DT >= 20200101
 AND A.TRADE_DT <= 20210804
 UNION ALL
 SELECT SK_PRIMARY_KEY
 FROM T05_BANK_REPUR_TRAN_INFO A
 WHERE A.SYSTEM_SOURCE = 'S20'
 AND A.TRADE_DT >= 20200101
 AND A.TRADE_DT <= 20210804
  )
) B
回购持仓表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       nvl(A.SOURCE_VALUE,0) AS SOURCE_VALUE,
       nvl(B.TARGET_VALUE,0) AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT COUNT(*) SOURCE_VALUE
FROM(
SELECT NVL(A.c_port_code,B.c_port_code) AS c_port_code
FROM (
SELECT c_port_code,D_ASTSTAT,C_SEC_CODE
FROM S20_T_R_FR_ASTSTAT A
WHERE A.c_nav_type = 'CACH_SEC' 
AND A.C_DAI_CODE in('MCHGJRZC','MRFSJRZC')
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804)A
FULL JOIN 
(SELECT c_port_code,D_ASTSTAT,C_SEC_CODE
FROM S20_T_R_FR_ASTSTAT A
WHERE A.C_SEC_VAR_CODE LIKE 'HG%' 
AND A.C_KEY_CODE = 'YSLX_ZQ'
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804)B
ON A.c_port_code = B.c_port_code
AND A.D_ASTSTAT = B.D_ASTSTAT
AND A.C_SEC_CODE = B.C_SEC_CODE
)
) A
, (
SELECT  count(*) as TARGET_VALUE
from T09_REPO_POSITION
WHERE SYSTEM_SOURCE = 'S20'
AND POSITION_DT >= 20200101
AND POSITION_DT <= 20210804
) B
基金成交信息条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT SUM(SOURCE_VALUE) SOURCE_VALUE FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_D_AC_TRADE_IVT A
LEFT JOIN S20_T_P_SV_SEC_BASE D
ON A.C_SEC_CODE = D.C_SEC_CODE
WHERE A.N_CHECK_STATE = 1
AND A.C_TD_TYPE = 'JJJY'
AND D.N_CHECK_STATE = 1
AND A.C_PORT_CODE IN  (SELECT DISTINCT FUND_CODE
                       FROM T02_PROD_BASICINFO
             WHERE FUND_CODE = A.C_PORT_CODE
             AND NET_WP_WAY = '0')
AND CASE WHEN INSTR(D.C_SEC_VAR_CODE, '_') = 0 THEN D.C_SEC_VAR_CODE ELSE SUBSTR(D.C_SEC_VAR_CODE,0,INSTR(D.C_SEC_VAR_CODE, '_') - 1) END = 'JJ'
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) <= 20210804
UNION ALL
SELECT COUNT(*) SOURCE_VALUE
FROM S20_T_D_AC_TRADE_SALE A
LEFT JOIN S20_T_P_SV_SEC_BASE D
ON A.C_SEC_CODE = D.C_SEC_CODE
WHERE A.N_CHECK_STATE = 1
AND D.N_CHECK_STATE = 1
AND A.C_TD_TYPE = 'CWSS'
AND A.C_PORT_CODE IN  (SELECT DISTINCT FUND_CODE
                       FROM T02_PROD_BASICINFO
             WHERE FUND_CODE = A.C_PORT_CODE
             AND NET_WP_WAY = '0')
AND CASE WHEN INSTR(D.C_SEC_VAR_CODE, '_') = 0 THEN D.C_SEC_VAR_CODE ELSE SUBSTR(D.C_SEC_VAR_CODE,0,INSTR(D.C_SEC_VAR_CODE, '_') - 1) END = 'JJ'
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) <= 20210804
)) A
, (
SELECT  count(*) as TARGET_VALUE
from T05_FUND_TRANSACTION_INFO A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
) B
基金持仓表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_R_FR_ASTSTAT A
LEFT JOIN S20_T_P_SV_SEC_BASE C
ON A.C_SEC_CODE = C.C_SEC_CODE
WHERE A.C_NAV_TYPE IN ('SEC', 'CACH')
AND C.C_SEC_VAR_CODE LIKE 'JJ%'
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804
) A
, (
SELECT  count(*) as TARGET_VALUE
from T09_HOLD_FUND
WHERE SYSTEM_SOURCE = 'S20'
AND POSITION_DT >= 20200101                 AND POSITION_DT <= 20210804
) B
基金持仓市值总额数值验证

SELECT
    'S20' AS DATA_SOURCE,
    TRADE_DT AS BUSS_DATE, --如果没有业务日期就和LOG_DATE相等
    'T09_HOLD_FUND' AS SOURCE_TABLE_NAME, --源表名
    'POSI_MKT_VAL' AS SOURCE_COLUMN_NAME, --源列名
    nvl(SOURCE_VALUE,0) as SOURCE_VALUE, --源数据值
    'T10_BALANCESHEET' AS TARGET_TABLE_NAME, --目标表名
    'FUND_INVESTMENT_VAL_IN_TOTAL' AS TARGET_COLUMN_NAME, --目标列名
    nvl(TARGET_VALUE,0) as TARGET_VALUE, --目标数据值
    (CASE
        WHEN nvl(SOURCE_VALUE,0) = nvl(TARGET_VALUE,0) THEN '1'
        ELSE '2'
    END) AS STATUS,
    NULL AS REMARKS,
    '1' AS VERIFICATION_TOTAL_NUM,
    (CASE
        WHEN nvl(SOURCE_VALUE,0) = nvl(TARGET_VALUE,0) THEN '0'
        ELSE '1'
    END) AS ISSUE_NUM,
    SK_F_PROD AS SK_F_PROD,
    20200101 AS START_DT,
    20210804 AS END_DT
FROM (SELECT A.SK_F_PROD AS SK_F_PROD,
            A.TRADE_DT AS TRADE_DT,
			--TO_CHAR(SYSDATE,'YYYYMMDD') AS TRADE_DT,
            B.SOURCE_VALUE,
            --'LOCC_POSI_MKT_VAL' AS TARGET_COLUMN_NAME,
            A.TARGET_VALUE AS TARGET_VALUE
        FROM --源表明细
        (
SELECT A.SK_F_PROD,
                    A.POSITION_DT,
                    SUM(A.POSI_MKT_VAL) SOURCE_VALUE
               FROM T09_HOLD_FUND A
              WHERE SYSTEM_SOURCE = 'S20'
                AND A.POSITION_DT >= 20200101
                AND A.POSITION_DT <= 20210804
              GROUP BY A.SK_F_PROD, A.POSITION_DT) B
        RIGHT JOIN
        --目标表明细
        (
SELECT SK_F_PROD,
               TRADE_DT,
               FUND_INVESTMENT_VAL_IN_TOTAL TARGET_VALUE
          FROM T10_BALANCESHEET
         WHERE SYSTEM_SOURCE = 'S20'
           AND TRADE_DT >= 20200101
           AND TRADE_DT <= 20210804) A 
ON B.POSITION_DT = A.TRADE_DT
AND B.SK_F_PROD = A.SK_F_PROD
		)
逆回购持仓市值总额数值验证

SELECT
    'S20' AS DATA_SOURCE,
    TRADE_DT AS BUSS_DATE, --如果没有业务日期就和LOG_DATE相等
    'T09_REPO_POSITION' AS SOURCE_TABLE_NAME, --源表名
    'POSI_MKT_VAL' AS SOURCE_COLUMN_NAME, --源列名
    nvl(SOURCE_VALUE,0), --源数据值
    'T10_BALANCESHEET' AS TARGET_TABLE_NAME, --目标表名
    'FINANCIAL_ASF_REPURCHASE' AS TARGET_COLUMN_NAME, --目标列名
    nvl(TARGET_VALUE,0), --目标数据值
    (CASE
        WHEN nvl(SOURCE_VALUE,0) = nvl(TARGET_VALUE,0) THEN '1'
        ELSE '2'
    END) AS STATUS,
    NULL AS REMARKS,
    '1' AS VERIFICATION_TOTAL_NUM,
    (CASE
        WHEN nvl(SOURCE_VALUE,0) = nvl(TARGET_VALUE,0) THEN '0'
        ELSE '1'
    END) AS ISSUE_NUM,
    SK_F_PROD AS SK_F_PROD,
    20200101 AS START_DT,
    20210804 AS END_DT
FROM (SELECT A.SK_F_PROD AS SK_F_PROD,
            A.TRADE_DT AS TRADE_DT,
			--TO_CHAR(SYSDATE,'YYYYMMDD') AS TRADE_DT,
            B.SOURCE_VALUE,
            --'LOCC_POSI_MKT_VAL' AS TARGET_COLUMN_NAME,
            A.TARGET_VALUE AS TARGET_VALUE
        FROM --源表明细
        (
SELECT A.SK_F_PROD,
                    A.POSITION_DT,
                    -1 * ABS(SUM(A.POSI_MKT_VAL)) SOURCE_VALUE
               FROM T09_REPO_POSITION A
              WHERE SYSTEM_SOURCE = 'S20'
                AND REPURCHASE_DIRECTION = '2'
                AND A.POSITION_DT >= 20200101
                AND A.POSITION_DT <= 20210804
              GROUP BY A.SK_F_PROD, A.POSITION_DT) B
        RIGHT JOIN
        --目标表明细
        (
SELECT SK_F_PROD,
               TRADE_DT,
               -1 * ABS(BUYING_BTSOF_ASS) TARGET_VALUE
          FROM T10_BALANCESHEET
         WHERE SYSTEM_SOURCE = 'S20'
           AND TRADE_DT >= 20200101
           AND TRADE_DT <= 20210804) A
ON B.POSITION_DT = A.TRADE_DT
AND B.SK_F_PROD = A.SK_F_PROD
		)
期货成交表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_D_AC_TRADE_IVT A
LEFT JOIN S20_T_P_SV_SEC_BASE D
ON A.C_SEC_CODE = D.C_SEC_CODE
WHERE A.N_CHECK_STATE = 1
AND A.C_TD_TYPE = 'QHJY'
AND D.N_CHECK_STATE = 1
AND A.C_PORT_CODE IN (SELECT DISTINCT FUND_CODE
                      FROM T02_PROD_BASICINFO
					  WHERE FUND_CODE = A.C_PORT_CODE
					  AND NET_WP_WAY = '0')
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(A.D_TRADE, 'yyyymmdd')) <= 20210804
) A
, (
SELECT  count(*) as TARGET_VALUE
from T05_FUTURES_TRANS_INFO A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
  ) B
期货持仓表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_R_FR_ASTSTAT A
LEFT JOIN S20_T_P_SV_SEC_BASE C
ON A.C_SEC_CODE = C.C_SEC_CODE
WHERE A.C_NAV_TYPE = 'SEC'
AND C.C_SEC_VAR_CODE LIKE 'QH%'
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804
) A
, (
SELECT  count(*) as TARGET_VALUE
from T09_FUTURES_POSITION
WHERE SYSTEM_SOURCE = 'S20'
AND POSITION_DT >= 20200101
AND POSITION_DT <= 20210804
) B
债券成交信息条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT COUNT(*) AS SOURCE_VALUE
FROM(
SELECT  C_PORT_CODE,D_TRADE,C_MKT_CODE
FROM  T02_PROD_BASICINFO T1,
  (SELECT C_PORT_CODE,D_TRADE,C_MKT_CODE
   FROM S20_T_D_AC_TRADE_IVT A
   WHERE A.N_CHECK_STATE = 1 AND A.C_TD_TYPE = 'ZQJY'
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')
   UNION ALL
   --上市流通
   SELECT C_PORT_CODE,D_TRADE,C_MKT_CODE
   FROM S20_T_D_AC_TRADE_SL A
   WHERE A.N_CHECK_STATE = 1 AND A.C_SEC_VAR_CODE LIKE 'ZQ%'
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')
   UNION ALL
   --新债
   SELECT A.C_PORT_CODE,A.D_TRADE,A.C_MKT_CODE
   FROM S20_T_D_AC_TRADE_IPO A
   LEFT JOIN S20_T_P_SV_SEC_BASE C
          ON A.C_SEC_CODE = C.C_SEC_CODE
   WHERE A.N_CHECK_STATE = 1 AND C.C_SEC_VAR_CODE LIKE 'ZQ%'
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')) T2
WHERE T1.FUND_CODE = T2.C_PORT_CODE AND T1.NET_WP_WAY ='0'
  AND T2.C_MKT_CODE IN ('XCFE','OOTC','COTC')
UNION ALL
SELECT C_PORT_CODE,D_TRADE,C_MKT_CODE
FROM   T02_PROD_BASICINFO T1,
  (SELECT A.C_PORT_CODE,A.D_TRADE,A.C_MKT_CODE
   FROM S20_T_D_AC_TRADE_IVT A
   WHERE A.N_CHECK_STATE = 1 AND A.C_TD_TYPE = 'ZQJY'
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')
   UNION ALL
   --上市流通
   SELECT A.C_PORT_CODE,A.D_TRADE,A.C_MKT_CODE
   FROM S20_T_D_AC_TRADE_SL A
   WHERE A.N_CHECK_STATE = 1 AND A.C_SEC_VAR_CODE LIKE 'ZQ%'
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')
   UNION ALL
   --新债
   SELECT A.C_PORT_CODE,A.D_TRADE,A.C_MKT_CODE
   FROM S20_T_D_AC_TRADE_IPO A
       LEFT JOIN S20_T_P_SV_SEC_BASE C
          ON A.C_SEC_CODE = C.C_SEC_CODE
   WHERE A.N_CHECK_STATE = 1 AND C.C_SEC_VAR_CODE LIKE 'ZQ%'
     AND A.D_TRADE >= to_date(20200101,'yyyymmdd') 
     AND A.D_TRADE <= to_date(20210804,'yyyymmdd')) T2
WHERE T1.FUND_CODE = T2.C_PORT_CODE AND T1.NET_WP_WAY ='0'
  AND T2.C_MKT_CODE NOT IN ('XCFE','OOTC','COTC')
)
) A
, (
SELECT count(*) AS TARGET_VALUE
FROM(
SELECT  SK_PRIMARY_KEY--count(*) as TARGET_VALUE
FROM T05_EXCH_BOND_TRAN_INFO A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
UNION ALL
SELECT SK_PRIMARY_KEY--COUNT(*) TARGET_VALUE
FROM T05_BANK_BOND_TRAN_INFO A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
)
) B
--债券持仓表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_R_FR_ASTSTAT A
LEFT JOIN S20_T_P_SV_SEC_BASE C
ON A.C_SEC_CODE = C.C_SEC_CODE
WHERE A.C_NAV_TYPE IN ('SEC', 'CACH')
AND C.C_SEC_VAR_CODE LIKE 'ZQ%'
AND A.C_KEY_CODE <> 'YSLX_ZQ'
AND A.C_DAI_CODE <> 'ZQTZ_YZJ'
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(D_ASTSTAT, 'yyyymmdd')) <= 20210804
) A
, (
SELECT  count(*) as TARGET_VALUE
from T09_HOLD_BOND
WHERE SYSTEM_SOURCE = 'S20'
AND POSITION_DT >= 20200101
AND POSITION_DT <= 20210804
and SECU_ATTR is not null
) B
正回购持仓市值总额数值验证
SELECT 'S20' AS DATA_SOURCE,
       TRADE_DT AS BUSS_DATE,
       'T09_REPO_POSITION' AS SOURCE_TABLE_NAME,
       'POSI_MKT_VAL' AS SOURCE_COLUMN_NAME,
       NVL(SOURCE_VALUE,0) AS SOURCE_VALUE ,
       'T10_BALANCESHEET' AS TARGET_TABLE_NAME,
       'BUYING_BTSOF_ASS' AS TARGET_COLUMN_NAME,
       nvl(TARGET_VALUE,0) as TARGET_VALUE,
       (CASE
         WHEN nvl(SOURCE_VALUE,0) = nvl(TARGET_VALUE,0) THEN
          '1'
         ELSE
          '2'
       END) AS STATUS,
       NULL AS REMARKS,
       '1' AS VERIFICATION_TOTAL_NUM,
       (CASE
         WHEN nvl(SOURCE_VALUE,0) = nvl(TARGET_VALUE,0) THEN
          '0'
         ELSE
          '1'
       END) AS ISSUE_NUM,
       SK_F_PROD AS SK_F_PROD,
       20200101 AS START_DT,
       20210804 AS END_DT
  FROM (SELECT A.SK_F_PROD    AS SK_F_PROD,
               A.TRADE_DT     AS TRADE_DT,
               B.SOURCE_VALUE,
               A.TARGET_VALUE AS TARGET_VALUE
          FROM (SELECT A.SK_F_PROD,
                       A.POSITION_DT,
                       SUM(A.POSI_MKT_VAL) SOURCE_VALUE
                  FROM T09_REPO_POSITION A
                 WHERE SYSTEM_SOURCE = 'S20'
                   AND REPURCHASE_DIRECTION = '1'
                   AND A.POSITION_DT >= 20200101
                   AND A.POSITION_DT <= 20210804
                 GROUP BY A.SK_F_PROD, A.POSITION_DT) B
         RIGHT JOIN (SELECT SK_F_PROD,
                           TRADE_DT,
                           FINANCIAL_ASF_REPURCHASE TARGET_VALUE
                      FROM T10_BALANCESHEET
                     WHERE SYSTEM_SOURCE = 'S20'
                       AND TRADE_DT >= 20200101
                       AND TRADE_DT <= 20210804) A
            ON B.POSITION_DT = A.TRADE_DT
           AND B.SK_F_PROD = A.SK_F_PROD)
指数权重日频数据指数样本权重和验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       SK_F_IDX||'|'||TRADE_DT AS SK_F_PROD,
       abs(sw - 100) as SOURCE_VALUE,
       1 AS TARGET_VALUE,
       1 AS CNT,
       'SK_F_IDX"|"TRADE_DT"="'||
               SK_F_IDX||
               '|'|| TRADE_DT
                AS REMARK
  from (select SK_F_IDX, TRADE_DT, sum(weight) as sw
          from SDI_INDEX_WEIGHTS_D
         where trade_dt >= ${start_date}
           and trade_dt <= ${end_date}
         group by SK_F_IDX, TRADE_DT) a
指数行情日频数据表与财汇源表数据条数验证
select to_char(SYSDATE, 'YYYYMMDD') as BUSS_DATE,
       B.trade_dt as SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT,
       CONCAT('trade_dt=', B.trade_dt) AS REMARK
  from (select F.CALENDAR_DT, count(*) SOURCE_VALUE
          FROM S02_TQ_IX_BASICINFO A --指数基本资料表
         INNER JOIN (SELECT SECODE,
                           EXCHANGE,
                           ROW_NUMBER() OVER(PARTITION BY SECODE ORDER BY BEGINDATE DESC) RN
                      FROM S01_TQ_OA_STCODE
                     WHERE ISVALID = 1) B
            ON B.SECODE = A.SECODE
           AND RN = 1
          LEFT JOIN (SELECT ENUM_CODE, ENUM_NAME, SOURCE_ENU_VALUE
                      FROM T00_SINITEK_SOURCE_MAPPING
                     WHERE SINITEK_TABLE = 'XN_TABLES' -- 目标表
                       AND SINITEK_FIELD = 'MKT_CODE' -- 目标字段
                       AND SOURCE = 'S02' -- 数据来源
                       AND SOURCE_TABLE = 'S02_TABLES' -- 源表
                       AND SOURCE_FIELD = 'NEWFINCHINA_FIELD' -- 源字段
                    ) D
            ON D.SOURCE_ENU_VALUE = B. EXCHANGE
         INNER JOIN T00_TRADEDATE_EXTEND F
            ON F.MKT_CODE = (CASE
                 WHEN D.ENUM_CODE IN ('001', '002', '003', '004') then
                  d.ENUM_CODE
                 else
                  '001'
               end)
         WHERE F.CALENDAR_DT >= A.PUBLISHDATE
           AND (F.CALENDAR_DT <= A.ENDDATE OR
               A.ENDDATE = '19000101')
           AND F.CALENDAR_DT >= ${start_date}
           AND F.CALENDAR_DT <= ${end_date}
           AND A.STATUS = '1' --是否使用
         GROUP BY F.CALENDAR_DT) A
  LEFT JOIN (select trade_dt , count(*) TARGET_VALUE
               from SDI_index_quote_d
              where trade_dt BETWEEN ${start_date} AND ${end_date}
              GROUP BY trade_dt) B
    ON A.CALENDAR_DT =B.trade_dt
质押证券成交表条数验证
SELECT to_char(SYSDATE, 'YYYYMMDD') AS BUSS_DATE,
       NULL AS SK_F_PROD,
       A.SOURCE_VALUE AS SOURCE_VALUE,
       B.TARGET_VALUE AS TARGET_VALUE,
       1 AS CNT
FROM(
SELECT  COUNT(*) SOURCE_VALUE
FROM S20_T_D_AC_TRADE_ZYW A
LEFT JOIN S20_T_D_AC_TRADE_IVT B
ON A.C_IDEN_RELA = B.C_IDEN
WHERE B.C_IDEN IS NOT NULL
AND B.N_CHECK_STATE = 1
AND TO_NUMBER(TO_CHAR(B.D_TRADE, 'yyyymmdd')) >= 20200101
AND TO_NUMBER(TO_CHAR(B.D_TRADE, 'yyyymmdd')) <= 20210804
) A
, (
SELECT  count(*) as TARGET_VALUE
from T05_PLEDGE_SECU A
WHERE A.SYSTEM_SOURCE = 'S20'
AND A.TRADE_DT >= 20200101
AND A.TRADE_DT <= 20210804
) B


--产品成交表数据不唯一
SELECT * FROM(
SELECT  BUSS_DATE,SK_F_PROD,COUNT(1) ct FROM(
SELECT A.TRADE_DT AS BUSS_DATE,
       A.SK_F_PROD ||'|'||SECU_CODE||'|'||A.BUSS_TYPE||'|'||TRANS_DIRECTION AS SK_F_PROD, 
       NULL AS SOURCE_VALUE,
       NULL AS TARGET_VALUE,
       1 AS CNT,
       concat('SK_F_PROD| TRADE_DT=',
              concat(A.SK_F_PROD, A.TRADE_DT)) as REMARKS
  from (select SK_F_PROD,
               TRADE_DT,
               COUNT(*) as TARGET_VALUE,
               SECU_CODE,
               BUSS_TYPE,
               TRANS_DIRECTION
          from  SDI_PROD_TRANS_SUM
         where TRADE_DT between 20200101 AND 20210804
         group by SK_F_PROD, TRADE_DT,SECU_CODE,BUSS_TYPE,TRANS_DIRECTION,TRANS_NUM,TRADE_SEAT
        having count(*) > 1) A
union all 
SELECT 1 AS BUSS_DATE, 
       NULL AS SK_F_PROD,
       '1' AS SOURCE_VALUE,
       '1' AS TARGET_VALUE,
       count(FINE_COUNT) AS CNT,
       NULL as REMARKS
  from (select SK_F_PROD, TRADE_DT, COUNT(*) as FINE_COUNT
          from  SDI_PROD_TRANS_SUM
         where TRADE_DT between 20200101 AND 20210804
         group by SK_F_PROD, TRADE_DT,SECU_CODE,BUSS_TYPE,TRANS_DIRECTION,TRANS_NUM,TRADE_SEAT
        having count(*) = 1) B
) cc GROUP BY BUSS_DATE,SK_F_PROD )WHERE ct> 1

--持仓汇总表中申万行业为空	
SELECT distinct to_number(to_char(sysdate, 'yyyymmdd')) AS BUSS_DATE,
                SK_F_PROD || '|' || POSITION_DT || '|' || SK_F_SECU AS SK_F_PROD,
                NULL AS SOURCE_VALUE,
                NULL AS TARGET_VALUE,
                1 AS CNT,
                concat('SW_INST_NAME_LVL1 = ', A.SW_INST_NAME_LVL1) as REMARKS
  from (select *
          from ${owner_name}.c12_prod_hold_summary
         WHERE (SW_INST_NAME_LVL1 IS NULL OR SW_INST_NAME_LVL1 = ' ')
           and POSITION_DT between ${start_dt} and ${end_dt}
           AND SECU_VAR IN ('股票品种', '债券品种')
           AND SUBJ_NAME not like '%国债%'
           AND SUBJ_NAME not like '%山西%'
           AND SUBJ_NAME not like '%云南%'
           AND SUBJ_NAME not like '%河北%'
           AND SUBJ_NAME not like '%厦门%'
           AND SUBJ_NAME not like '%浙江%'
           AND SUBJ_NAME not like '%重庆%'
           AND SUBJ_NAME not like '%河南%'
           AND SUBJ_NAME not like '%辽宁%'
           AND SUBJ_NAME not like '%广东%'
           AND SUBJ_NAME not like '%江西%'
           AND SUBJ_NAME not like '%内蒙%'
           AND SUBJ_NAME not like '%深圳%'
           and sk_f_prod not like 'PD12%') A
UNION ALL
SELECT to_number(to_char(sysdate, 'yyyymmdd')) AS BUSS_DATE,
       NULL AS SK_F_PROD,
       '1' AS SOURCE_VALUE,
       '1' AS TARGET_VALUE,
       FINE_COUNT AS CNT,
       NULL as REMARKS
  from (select (total_count - issue_count) as FINE_COUNT
          FROM (select count(*) total_count
                  from ${owner_name}.c12_prod_hold_summary
                 where POSITION_DT between ${start_dt} and ${end_dt}
                   AND SECU_VAR IN ('股票品种', '债券品种')) m,
               (select count(*) issue_count
                  from ${owner_name}.c12_prod_hold_summary
                 WHERE (SW_INST_NAME_LVL1 IS NULL OR SW_INST_NAME_LVL1 = ' ')
                   and POSITION_DT between ${start_dt} and ${end_dt}
                   AND SECU_VAR IN ('股票品种', '债券品种')
                   AND SECU_VAR IN ('股票品种', '债券品种')
                   AND SUBJ_NAME not like '%国债%'
                   AND SUBJ_NAME not like '%山西%'
                   AND SUBJ_NAME not like '%云南%'
                   AND SUBJ_NAME not like '%河北%'
                   AND SUBJ_NAME not like '%厦门%'
                   AND SUBJ_NAME not like '%浙江%'
                   AND SUBJ_NAME not like '%重庆%'
                   AND SUBJ_NAME not like '%河南%'
                   AND SUBJ_NAME not like '%辽宁%'
                   AND SUBJ_NAME not like '%广东%'
                   AND SUBJ_NAME not like '%江西%'
                   AND SUBJ_NAME not like '%内蒙%'
                   AND SUBJ_NAME not like '%深圳%'
                   and sk_f_prod not like 'PD12%') n) B
