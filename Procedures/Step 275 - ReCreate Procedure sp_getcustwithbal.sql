ALTER PROCEDURE [dbo].[sp_getcustwithbal]
	-- Add the parameters for the stored procedure here
	@BookId int,
	@status int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select convert(bit,0) as [ ],b.CustId as ID,a.custnum as [Acct #],a.custname as Name,a.bilstadd + ' ' + a.bilctadd as [Address]
		
	,isnull(b.meterno1,'') as [Meter #],isnull(b.Pread1,0) as [Last Meter Reading]
	,isnull(d.minbill,0) as [Minimum]
	,rtrim(ltrim(a.cbank_ref)) as [ATM Ref #],a.BillNum as [Bill #]
	from Members b
	left join cust a
	on b.CustId = a.CustId
	left join bill d
	on a.RateId = d.RateId
	and a.ZoneId = d.ZoneId
	left join vw_ledger e
	on a.CustId = e.CustId
	where b.BookId = @BookId
	and isnull(e.[Total Balance],0) >= d.MinBill
	and (a.status = (@status + 1))

END
