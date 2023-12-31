ALTER PROCEDURE  [dbo].[sp_CSSBC_BillStatus]
	-- Add the parameters for the stored procedure here
	@Billdate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select a.bookno,a.area,a.billdate
	,sum(isnull(case when d.billamnt is null and isnull(g.[Water Balance],0.00) > 1 then 1 end,0)) as Remedial,
	sum(isnull(case when c.status=1 and e.cons1>=0 and d.billamnt is null then 1 end,0)+
	isnull(case when c.status>1 and e.cons1>0 and d.billamnt is null then 1 end,0)) as forBilling,
	sum(isnull(case when d.billstat=1 and d.billamnt is not null then 1 end,0)) as NewBill,
	sum(isnull(case when d.billstat>1 and d.billamnt is not null then 1 end,0)) as PostedBill,
	f.newpay as NewPay,
	sum(isnull(case when d.billstat=3 then 1 end,0)) as PaidBill 
	FROM Books a 
	INNER JOIN Members b 
	on a.BookId=b.BookId 
	INNER JOIN Cust c 
	on b.CustId=c.CustId 
	LEFT JOIN Cbill d 
	on b.CustId=d.CustId 
	and d.billdate=@billdate
	LEFT JOIN Rhist e 
	on d.RhistId=e.RhistId
	LEFT JOIN
	(
		select count(1) as newpay,b.BookId 
		from cpaym a 
		INNER JOIN members b 
		on a.CustId = b.CustId 
		where a.PymntStat='1' group by b.BookId 
	)
	f on f.BookId=a.BookId
	LEFT JOIN Vw_Ledger g
	on b.CustId = g.CustId
	where a.billdate=@billdate
	group by a.bookno,a.area,a.billdate,f.newpay

END


