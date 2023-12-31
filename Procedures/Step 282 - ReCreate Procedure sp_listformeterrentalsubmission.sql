ALTER PROCEDURE [dbo].[sp_listformeterrentalsubmission]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@BookId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select case 
	when b.subtot5 > 0 then convert(bit,1)
	else convert(bit,0)
	end as [x] 
	,case 
	when b.subtot5 > 0 then convert(bit,1)
	else convert(bit,0)
	end as [With/Without]
	,c.CustNum as [Acct #]
	,custname as [Name]
	,b.BillNum
	,convert(numeric(18,2),subtot5) as [Meter Rental]
	from rhist a
	inner join cbill b
	on a.RhistId = b.RhistId
	and b.BillStat = 1
	inner join cust c
	on a.CustId = c.CustId
	where a.BillDate = @billdate
	and a.BookId = @BookId
END
