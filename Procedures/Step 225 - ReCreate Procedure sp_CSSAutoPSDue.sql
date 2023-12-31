ALTER PROCEDURE [dbo].[sp_CSSAutoPSDue]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

	Declare @temp as int;

	set @temp=(Select varvalue from variable where varname='PSDatedays')

	Select a.BillDate,a.BookId,c.BookNo,a.DueDate 
	FROM
	(
		Select distinct cbill.billdate,members.BookId,cbill.duedate from cbill
		inner join members
		on cbill.CustId = members.CustId
		and convert(varchar(100),convert(datetime,cbill.duedate),111) < convert(varchar(100),dateadd(day,0,getdate()),111)
		and cbill.billdate >= left(convert(varchar(100),dateadd(month,-1,getdate()),111),7)
		and cbill.BillStat <> 1 and cbill.BillDate >='2021/02'
	)a
	LEFT JOIN
	(
		Select distinct CbillOthers.billdate,members.BookId from cbillothers
		INNER JOIN Cust
		on CBillOthers.CustId = Cust.CustId
		inner join members
		on Cust.CustId = members.CustId
		and CbillOthers.billdate >= left(convert(varchar(100),dateadd(month,-1,getdate()),111),7) and CbillOthers.BillDate >= '2021/02'
	)b
	on a.BillDate = b.BillDate
	and a.BookId = b.BookId
	LEFT JOIN Books c
	on a.BookId = c.BookId
	where b.billdate is null
	and b.BookId is null
	and a.billdate >= '2019/10'

	UNION
	SELECT DISTINCT
	a.[BillDate],b.BookId, c.[BookNo], a.[DueDate]
	FROM
	[Cbill] a
	INNER JOIN [Members] b
	ON a.CustId = b.CustId
	LEFT JOIN Books c
	on b.BookId = c.BookId
	WHERE
	[DueDate] >= CONVERT(VARCHAR(10), GETDATE(), 111)
	and a.billdate >= '2021/02'
	ORDER BY
	c.[BookNo], [BillDate], [DueDate]
END
