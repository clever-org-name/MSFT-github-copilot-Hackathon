WITH CusOrd AS (
    SELECT 
        cus.cus_id,
        cus.cus_nam,
        ord.ord_id,
        ord.ord_amt,
        ord.ord_dat,
        ROW_NUMBER() OVER (PARTITION BY cus.cus_id ORDER BY ord.ord_dat DESC) AS ord_rnk
    FROM 
        cus cus
    JOIN 
        ord ord ON cus.cus_id = ord.cus_id
    WHERE 
        ord.ord_dat >= DATEADD(year, -1, GETDATE())
),
OrdSta AS (
    SELECT 
        cus_id,
        COUNT(ord_id) AS tot_ord,
        SUM(ord_amt) AS tot_sal,
        AVG(ord_amt) AS avg_sal
    FROM 
        CusOrd
    GROUP BY 
        cus_id
)
SELECT 
    cus.cus_id,
    cus.cus_nam,
    os.tot_ord,
    os.tot_sal,
    os.avg_sal,
    (SELECT COUNT(*) FROM ord o WHERE o.cus_id = cus.cus_id AND o.ord_dat >= DATEADD(year, -1, GETDATE())) AS rec_ord,
    (SELECT MAX(ord_amt) FROM ord o WHERE o.cus_id = cus.cus_id) AS max_amt,
    (SELECT MIN(ord_amt) FROM ord o WHERE o.cus_id = cus.cus_id) AS min_amt
FROM 
    cus cus
JOIN 
    OrdSta os ON cus.cus_id = os.cus_id
WHERE 
    os.tot_sal > 1000
ORDER BY 
    os.tot_sal DESC;
