ALTER PROCEDURE [dbo].[sp_offset]
	-- Add the parameters for the stored procedure here
	@CustId int
	,@water money
	,@penalty money
	,@total money
	,@user varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(isnull(@water,0) > 0)
	BEGIN
		insert Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,credit,remark,username
		)
		values
		(
			@CustId,GETDATE(),GETDATE(),'','WATER','',9,@water,'GD Offset Total(' + convert(varchar(100),isnull(@total,0)) + ')'
			,@user
		)
	END
	IF(isnull(@penalty,0) > 0)
	BEGIN
		insert Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,credit,remark,username
		)
		values
		(
			@CustId,GETDATE(),GETDATE(),'','PENALTY','',9,@penalty,'GD Offset Total(' + convert(varchar(100),isnull(@total,0)) + ')'
			,@user
		)
	END
	IF(isnull(@total,0) > 0)
	BEGIN

		insert Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,credit,remark,username
		)
		values
		(
			@CustId,GETDATE(),GETDATE(),'','GUARANTEE DEPOSIT','',9,@total,'GD Offset Total(' + convert(varchar(100),isnull(@total,0)) + ')'
			,@user
		)
	END
END
