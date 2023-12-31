ALTER PROCEDURE [dbo].[sp_rebateforentry]
	-- Add the parameters for the stored procedure here
	@BookId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select convert(bit,0) as [x]
	,a.CustId
	,a.custnum as [Acct #]
	,CustName as [Name]
	,BilStAdd + ' ' + BilCtAdd as [Address]
	,b.[Water Balance]
	,(b.[Water Balance] * -1) / 6 as [Monthly]
	from cust a
	INNER JOIN vw_ledger b
	on a.CustId = b.CustId
	INNER JOIN Members c
	on a.CustId = c.CustId
	LEFT JOIN Rebate_Entries d
	on a.CustId = d.CustId
	and d.rebate_balance > 0
	where b.[Water Balance] < 0
	and c.BookId = @BookId
	order by a.CustNum
END
