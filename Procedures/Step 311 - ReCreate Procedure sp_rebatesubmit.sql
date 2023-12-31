ALTER PROCEDURE [dbo].[sp_rebatesubmit]
	-- Add the parameters for the stored procedure here
	@RebateId int
	,@CustId int
	,@amount money
	,@billdate varchar(7)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(not exists(Select CustId from rebate_monthly where RebateId = @RebateId and billdate = @billdate))
	BEGIN
		insert rebate_monthly
		(
			RebateId,
			CustId
			,amount
			,billdate
			,submit_date
		)
		values
		(
			@RebateId,@CustId,@amount,@billdate
			,getdate()
		)

		update rebate_entries
		set rebate_balance = rebate_balance - @amount
		where RebateId = @rebateid

		insert cust_ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
			,transaction_type,debit,credit,remark,username
		)
		values
		(
			@CustId,getdate(),getdate(),@RebateId,'WATER','Rebate'
			,isnull((Select transaction_type from transaction_type where transaction_desc = 'Rebate'),0)
			,case when @amount > 0 then ABS(@amount) else 0 end
			,case when @amount < 0 then ABS(@amount) else 0 end
			,'Rebate for the Month:' + @billdate,''
		)

	END
END
