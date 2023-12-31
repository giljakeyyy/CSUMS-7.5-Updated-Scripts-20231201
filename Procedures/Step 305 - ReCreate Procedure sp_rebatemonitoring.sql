ALTER PROCEDURE [dbo].[sp_rebatemonitoring]
	-- Add the parameters for the stored procedure here
	@BookId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select RebateId as [ID],
	b.custnum as [Acct #]
	,custname as [Name]
	,bilstadd + ' ' + bilctadd as [Address]
	,rebate_amount [Total Amount Rebate]
	,rebate_monthly [Monthly Rebates]
	,rebate_balance [Remaining Rebates]
	,convert(varchar(30),entry_date,111) as [Entry Date]
	from rebate_entries a
	INNER JOIN Cust b
	on a.CustId = b.CustId
	INNER JOIN Members c
	on b.CustId = c.CustId
	where rebate_balance > 0
	and c.BookId = @BookId
END
