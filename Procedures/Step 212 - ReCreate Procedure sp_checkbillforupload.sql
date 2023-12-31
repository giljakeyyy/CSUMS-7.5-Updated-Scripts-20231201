ALTER PROCEDURE [dbo].[sp_checkbillforupload]
	-- Add the parameters for the stored procedure here
	@Unique_ID as varchar(100),
	@Acct_no as varchar(100),
	@cust_Name as varchar(100),
	@bilstadd as varchar(100),
	@bilctadd as varchar(100),
	@rate as varchar(100),
	@meterno1 as varchar(100),
	@billdate as varchar(100),
	@rdate as varchar(100),
	@Duedate as varchar(100),
	@pread1 as varchar(100),
	@read1 as varchar(100),
	@cons1  as varchar(100),
	@billamnt as varchar(100),
	@subtot2  as varchar(100),
	@subtot1 as varchar(100),
	@from as varchar(100),
	@to as varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	set @billdate = REPLACE(@billdate,'-','/')
	set @Duedate = REPLACE(@Duedate,'-','/')
	set @rdate = REPLACE(@rdate,'-','/')

	declare @CustId int
	declare @result varchar(100)

	set @CustId = isnull((Select top 1 CustId from cust where oldcustnum = @Acct_no),0)
	if(@CustId <> 0)
	begin
		if(not exists(Select CustId from rhist where CustId = @CustId and BillDate = @billdate))
		begin
			set @result = 'OK'
		end
		else
		begin
			set @result = 'Already Uploaded'
		end
	end
	else
	begin
		set @result = 'No Acct'
	end

	Select (Select custnum from Cust where CustId = @CustId) as custnum,@result as result
END
