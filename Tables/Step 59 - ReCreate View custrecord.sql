ALTER VIEW [dbo].[custrecord]
AS
	SELECT TOP 100 PERCENT c.CustNum, c.CustName, g.StatDesc, i.RateCd, a.BookNo, j.Zoneno, ISNULL(CAST(h.[Water Balance] AS nvarchar), '') AS cbal, a.BillDate, 
	ISNULL(CAST(e.Cons1 AS nvarchar), '') AS cons, ISNULL(CAST(d.SubTot1 AS nvarchar), '') AS bcharge, ISNULL(CAST(f.paycur AS nvarchar), '') AS paycur, 
	ISNULL(CAST(f.payarr AS nvarchar), '') AS payarr, ISNULL(CAST(f.payadv AS nvarchar), '') AS payadv, CASE WHEN d .subtot1 IS NULL 
	THEN '' ELSE CAST(d .subtot1 - isnull(f.paycur, 0) AS nvarchar) END AS bball, c.cbank_ref
	FROM dbo.Books a 
	LEFT OUTER JOIN
	dbo.Members b 
	ON a.BookId = b.BookId 
	LEFT OUTER JOIN
	dbo.Cust c 
	ON b.CustId = c.CustId 
	LEFT OUTER JOIN dbo.Cbill d 
	ON c.CustId = d.CustId AND d.BillDate = a.BillDate 
	LEFT OUTER JOIN dbo.Rhist e
	ON c.CustId = e.CustId AND e.BillDate = a.BillDate 
	LEFT OUTER JOIN
	(
		SELECT CustId, SUM(Subtot1) AS paycur, SUM(Subtot2) AS payarr, SUM(Subtot3) AS payadv, LEFT(PayDate, 7) AS paydt
		FROM dbo.Cpaym
		GROUP BY CustId, LEFT(PayDate, 7)
	) AS f 
	ON c.CustId = f.CustId AND f.paydt = a.BillDate 
	LEFT OUTER JOIN dbo.CustStat g 
	ON c.Status = g.StatCd
	LEFT OUTER JOIN Vw_Ledger h
	on c.CustId = h.CustId
	LEFT OUTER JOIN Rates i
	on c.RateId = i.RateId
	LEFT OUTER JOIN Zones j
	on c.ZoneId = j.ZoneId
	ORDER BY c.CustNum