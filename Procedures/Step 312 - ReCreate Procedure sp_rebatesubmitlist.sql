ALTER PROCEDURE [dbo].[sp_rebatesubmitlist]
	-- Add the parameters for the stored procedure here
	@BookId int,
	@billdate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select convert(bit,0) as [x],a.RebateId as [ID],
	b.CustId,
	b.custnum as [Acct #]
	,custname as [Name]
	,bilstadd + ' ' + bilctadd as [Address]
	,case when abs(rebate_monthly) <= abs(rebate_balance) then rebate_monthly
	else rebate_balance
	end as [For Rebate]
	from rebate_entries a
	INNER JOIN cust b
	on a.CustId = b.CustId
	LEFT JOIN Rebate_Monthly d
	on a.CustId = d.CustId
	and d.billdate = @billdate
	INNER JOIN Members c
	on b.CustId = c.CustId

	where rebate_balance != 0
	and d.RebateMonthlyId is null
	and c.BookId = @BookId
END
