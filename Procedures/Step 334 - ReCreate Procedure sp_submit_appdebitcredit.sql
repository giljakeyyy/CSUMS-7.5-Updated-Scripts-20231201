ALTER PROCEDURE [dbo].[sp_submit_appdebitcredit]
	-- Add the parameters for the stored procedure here
	@CustId int
	,@applnum varchar(100)
	,@jo_amount money
	,@actual_amount money
	,@totalpaid money
	,@amount money
	,@username varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert AppCreditDebit([CustId],[ApplNum],[AdjType],
	[JOAmount],[ActualAmount],[TotalPaid],
	[Amount],[TransDate],[Username])
	VALUES
	(
		@CustId,@applnum,case when @amount >= 0 then 1
		else 2 end,@jo_amount,@actual_amount,@totalpaid,case when @amount >= 0 then @amount
		else @amount * -1 end,getdate(),@username
	)

	insert Cust_Ledger
	(
		CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
		,transaction_type,debit,credit,remark,username
	)
	VALUES
	(
		@CustId,getdate(),getdate(),@applnum,'Water','App-Cust',4,case when @amount >= 0 then @amount else null end
		,case when @amount < 0 then @amount * -1 else null end,'Application JO to Customer',@username
	)

END
