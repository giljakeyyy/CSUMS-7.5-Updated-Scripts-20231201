ALTER PROCEDURE [dbo].[sp_submitcpaym] 
	-- Add the parameters for the stored procedure here
	@area_id int,
	@pymntnum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	Select @area_id as area_id
	,b.custnum
	,convert(varchar(20),paydate,111) as ums_date
	,0 as internal_id
	,convert(varchar(20),paydate,111) as posting_date
	,convert(varchar(20),paydate,111) as trans_date
	,a.pymntnum as refnum
	,'Collection' as ledger_type
	,'Water/Arrears' as ledger_subtype
	,202 as transaction_type
	,0 as previous_reading
	,0 as reading
	,0 as consumption
	,0.00 as debit
	,a.payamnt as credit
	,'' as duedate
	,'' as remark
	,rcvdby as username
	from cpaym a
	INNER JOIN Cust b
	on a.CustId = B.CustId
	where a.pymntnum = @pymntnum
END
