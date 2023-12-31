ALTER PROCEDURE [dbo].[sp_submitclosingbill]
	-- Add the parameters for the stored procedure here
	@CustId int
	,@billdate varchar(7),
	@previous int,
	@lastreading int,
	@consumption int,
	@basic money,
	@user varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	declare @table table (BillNum int primary key)

	insert ClosingBill
	(
		CustId,
		RDate,
		meterno1,
		previous,
		lastreading,
		consumption,
		amount1,
		amount2,
		amount3,
		amount4,
		amount5
	)
	
	OUTPUT Inserted.billnum into @table(billnum)
	Select CustId,getdate(),MeterNo1,@previous,@lastreading,@consumption,@basic,0,0,0,0 
	from members
	where CustId = @CustId

	insert into cust_ledger
	(
		CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
		,transaction_type,previous_reading,reading,consumption,debit
		,remark,username
	)
	Select b.CustId,getdate(),getdate(),a.billnum,'WATER','Closing Bill' 
	,10,b.previous,b.lastreading,b.consumption,b.amount1,'',@user
	from @table a
	inner join closing_bill b
	on a.billnum = b.billnum
	where a.billnum = b.billnum
	and b.CustId = @CustId

END
