ALTER PROCEDURE [dbo].[sp_disconsubmission]
	-- Add the parameters for the stored procedure here
	@CustId int,
	@usernme varchar(100),
	@discondate varchar(10),
	@discontype varchar(100),
	@billdate varchar(7),
	@amount money
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

	Declare @CustNum1 as varchar(20)
	Set @CustNum1 = (Select custnum from Cust Where CustId = @CustId)

	IF(@discontype <> 'Perm Mainline')
	BEGIN
		insert perm_disconnection(custnum,billdate)
		Select @CustNum1,@billdate
		where @CustNum1 not in
		(
			Select custnum
			from perm_disconnection where billdate = @billdate
		)
		
		update cust
		set
		status = 3,discdate = @discondate
		where CustId = @CustId


		insert cust_ledger(CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,remark,username)
		values(@CustId,GETDATE(),convert(datetime,@discondate),'','STATUS','Disconnection',6,@discontype,@usernme)

		if(@amount > 0)
		begin
			insert cust_ledger(CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit,remark,username)
			values(@CustId,GETDATE(),convert(datetime,@discondate),'','RECONNECTION','',1,@amount,@discontype,@usernme)
		end
	END
	ELSE IF(@discontype = 'Perm Mainline')
	BEGIN

		delete from perm_disconnection where custnum = @custnum1 and billdate = @billdate
		
		update cust
		set
		status = 3,discdate = @discondate
		where CustId = @CustId

		insert cust_ledger(CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,remark,username)
		values(@CustId,GETDATE(),convert(datetime,@discondate),'','STATUS','Disconnection',6,@discontype,@usernme)

		if(@amount > 0)
		begin
			insert cust_ledger(CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit,remark,username)
			values(@CustId,GETDATE(),convert(datetime,@discondate),'','RECONNECTION','',1,@amount,@discontype,@usernme)
		end															
	END
	
	insert Disconnection(custnum,billdate,discontype,discondate)
	values(@CustNum1,@billdate,@discontype,@discondate)

	update disconnection_type
	set discon_fee = @amount
	where discon_type = @discontype

END
