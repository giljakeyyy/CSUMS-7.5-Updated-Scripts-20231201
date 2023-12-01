ALTER VIEW [dbo].[monitoring]
AS
SELECT     TOP 100 PERCENT a.BookNo, a.GroupNo, a.Area, a.BillDate, SUM(ISNULL(CASE WHEN c.status > 1 AND d .billamnt IS NULL AND isnull(g.[Water Balance],0) > 10 THEN 1 END, 0)) 
                      AS NMWBal, SUM(ISNULL(CASE WHEN c.status = 1 AND e.cons1 >= 0 AND d .billamnt IS NULL THEN 1 END, 0) + ISNULL(CASE WHEN c.status > 1 AND 
                      e.cons1 > 0 AND d .billamnt IS NULL THEN 1 END, 0)) AS forBilling, SUM(ISNULL(CASE WHEN d .billamnt IS NOT NULL THEN 1 END, 0)) AS Billed, 
                      SUM(ISNULL(CASE WHEN d .billstat = 1 AND d .billamnt IS NOT NULL THEN 1 END, 0)) AS NewBill, SUM(ISNULL(CASE WHEN d .billstat > 1 AND 
                      d .billamnt IS NOT NULL THEN 1 END, 0)) AS PostedBill, SUM(ISNULL(CASE WHEN f.payamnt IS NOT NULL THEN 1 END, 0)) AS NewPay, 
                      SUM(ISNULL(CASE WHEN d .billstat = 3 THEN 1 END, 0)) AS PaidBill
FROM         dbo.Books AS a LEFT OUTER JOIN
                      dbo.Members AS b ON a.BookId = b.BookId LEFT OUTER JOIN
                      dbo.Cust AS c ON b.CustId = c.CustId LEFT OUTER JOIN
                      dbo.Cbill AS d ON c.CustId = d.CustId AND d.BillDate = a.BillDate LEFT OUTER JOIN
                      dbo.Rhist AS e ON c.CustId = e.CustId AND e.BillDate = a.BillDate LEFT OUTER JOIN
                      dbo.Cpaym AS f ON c.CustId = f.CustId AND f.PymntStat = '1'
					  LEFT OUTER JOIN vw_Ledger g
					  on c.CustId = g.CustId
GROUP BY a.BookNo, a.GroupNo, a.Area, a.BillDate
ORDER BY a.BookNo

