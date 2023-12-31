ALTER PROCEDURE [dbo].[sp_uploadbilling]
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

	set @CustId = 0

	set @CustId = isnull((Select top 1 CustId from cust where oldcustnum = @Acct_no),'')
	IF(@from = '' or @to = '' or @rdate = '' or @Duedate = '')
	BEGIN
		set @result = 'Error'
	END
	ELSE IF(@CustId <> 0)
	BEGIN
		IF(not exists(Select CustId from rhist where CustId = @CustId and BillDate = @billdate))
		BEGIN
			declare @Rhist table (RhistId int primary key)
			insert rhist
			(
				CustId,BookId,SeqNo,RateId,BillDate,Rdate,Rtime,Pread1,Read1,Cons1,Tries
				,nbasic,DueDate,billperiod,arrears
			)
			OUTPUT Inserted.RhistId into @Rhist(RhistId)
			Select top 1 a.CustId,b.BookId,SeqNo,RateId,@billdate,@rdate,'12:00',case when @pread1 = '' then null else @pread1 end
			,case when @read1 = '' then null else @read1 end,@cons1,1
			,@subtot1,substring(@Duedate,6,2) + '/' + right(@Duedate,2) + '/' + left(@duedate,4)
			,@from + ' - ' + @to
			,0.00 
			from cust a
			inner join Members b
			on a.CustId = b.CustId
			where a.CustId = @CustId

			declare @table table (billnum int primary key)

			insert cbill
			(
				CustId,RHistId,billdate,BillStat,BillAmnt,DueDate,Duedate2,BillDtls,RpayNum,subtot1,subtot2,subtot3,subtot4,subtot5
				,Dunning
			)
			OUTPUT Inserted.billnum into @table(billnum)
			Select top 1 a.custnum,(Select RhistId from @Rhist),
			@billdate,1,@billamnt,@DueDate,@Duedate,'Cadiz Water District'
			,'',@subtot1,@subtot2,0,0,0
			,'on or before due date.'
			from cust a
			inner join Members b
			on a.CustId = b.CustId
			where a.CustId = @CustId

			insert tbill
			(
				billnum,CustId,BillDate,BillPeriod,DueDate,TotalCharges,meterno
				,ratecd,PrevRdg,PresRdg,TotalCons
			)

			Select top 1 (Select billnum from @table),a.custnum,@BillDate
			,@from + ' to ' + @to
			,@DueDate,@subtot1,@meterno1
			,a.rateId,case when @pread1 = '' then null else @pread1 end,case when @read1 = '' then null else @read1 end,@cons1
			from cust a
			inner join Members b
			on a.CustId = b.CustId
			where a.CustId = @CustId

			set @result = 'Saved'
		END
		ELSE
		BEGIN
			set @result = 'Already Uploaded'
		END
	END
	ELSE
	BEGIN
		set @result = 'No Acct'
	END

	Select @CustId as CustId,CustNum,@result as result
	from Cust
	where CustId = @CustId
END
