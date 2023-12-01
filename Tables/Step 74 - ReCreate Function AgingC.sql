ALTER FUNCTION [dbo].[AgingC]
(	
	@year varchar(4),
	@month varchar(2)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT     a.CustId,c.CustNum, a.BillDate, 

CASE WHEN a.billdate = @year + '/' + @month
	 THEN a.billamnt  END AS [Current],
CASE WHEN a.billdate = CONVERT(varchar(7),DATEADD(month,-1,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
 THEN a.billamnt END AS Current1, 
CASE WHEN a.billdate = CONVERT(varchar(7),DATEADD(month,-2,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
THEN a.billamnt  END AS Current2,
CASE WHEN a.billdate <= CONVERT(varchar(7),DATEADD(month,-3,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01')+ '/' + CONVERT(VARCHAR(4), @year)))),111)
 THEN
    a.billamnt 
 END AS Over90
FROM dbo.Cbill AS a 
inner join Cust c
on a.CustId = c.CustId
left JOIN
dbo.Cpaym AS b ON a.CustId = b.CustId and a.BillDate = LEFT(b.PayDate,7)

                  

                      
WHERE   

a.billdate <= @year + '/' + @month
GROUP BY a.CustId,c.CustNum, a.BillDate, a.BillAmnt

)