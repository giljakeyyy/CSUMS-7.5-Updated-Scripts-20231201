ALTER PROCEDURE [dbo].[sp_CSSReading]
	-- Add the parameters for the stored procedure here
	@RhistId int,
	@CustId int,
	@BillDate varchar(7),
	@Pread1 varchar(10),
	@Read1 varchar(10),
	@Cons1 numeric(18),
	@Remark varchar(50),
	@xuser varchar(100),
	@Basic numeric(18,2),
	@Rdate varchar(10),
	@bp varchar(24),
	@duedate varchar(10),
	@cmd int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@RhistId> 0)
	BEGIN
			Insert into rhist_logs 
			(
				Custnum,Billdate,readdate,Pread1,Read1,Cons,Remarks,DtDate,Xuser,Commandtype
			)
			Select Custnum,Billdate,Rdate,Pread1,Read1,Cons1,Remark,GETDATE(),@xuser,'UPDATE' 
			from Rhist 
			INNER JOIN Cust
			on Rhist.CustId = Rhist.CustId
			where RhistId = @RhistId
	
			update Rhist set pread1=@Pread1,Read1=@Read1,Cons1=@Cons1,Remark=@Remark
			where RhistId = @RhistId

			declare @billnum varchar(30)
			set @billnum = isnull((Select billnum from cbill where RhistId = @RhistId),0)

			update cust_ledger
			set previous_reading = @pread1,reading = @read1,consumption = @Cons1
			where CustId=@CustId and refnum=convert(varchar(20),@Billnum) and transaction_type = 1
			and ledger_type = 'WATER'

	END
	ELSE IF (@RhistId<=0)
	BEGIN
		declare @duedate1 varchar(20)

		set @duedate1 = substring(convert(varchar(100),convert(datetime,@duedate),111),6,2) + '/' + 
		right(convert(varchar(100),convert(datetime,@duedate),111),2) + '/' +
		left(convert(varchar(100),convert(datetime,@duedate),111),4)
		
		declare @table table (RhistId int primary key,BookId int)
		Insert into Rhist 
		(
			CustId,BillDate,RateId,Rdate,pread1,Read1,cons1,Remark,BillPeriod,arrears,DueDate,BookId,rtime,nbasic,FF3Cd,CreatedDate
		)
		OUTPUT Inserted.RhistId,Inserted.BookId into @table(RhistId,BookId)
		Select a.CustId,@Billdate,b.RateId,@Rdate,@Pread1,@Read1,@Cons1,@Remark,@bp,c.[Water Balance],@duedate1,
		a.BookId,convert(varchar(10), GETDATE(), 108),@Basic,1,getdate()
		from Members a 
		INNER JOIN Cust b 
		on a.CustId=b.CustId 
		inner join vw_ledger c 
		on b.CustId = c.CustId 
		where a.CustId=@CustId
		
		set @RhistId = isnull((Select RhistId from @table),0)
		exec sp_CreateBill @RhistId
	END
END
