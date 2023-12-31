ALTER PROCEDURE [dbo].[sp_AddReading_v2]
	-- Add the parameters for the stored procedure here
	@CustNum varchar(20),
	@BookNo varchar(8),
	@SeqNo bigint,
	@Rate  varchar(5),
	@BillDate varchar(7),
	@Rdate varchar(20),
	@Rtime varchar(20),
	@Pread1 varchar(10),
	@Read1 varchar(10),
	@Cons1 varchar(10),
	@Pread2 varchar(10),
	@Read2 varchar(10),
	@Cons2 numeric(18,2),
	@RangeCd varchar(1),
	@Tries varchar(1),
	@MissCd varchar(1),
	@WarnCd varchar(1),
	@FF1Cd varchar(2),
	@FF2Cd varchar(2),
	@FF3Cd varchar(2),
	@Remark	 varchar(50),
	@nbasic varchar(20),
	@DueDate varchar(20),
	@BillPeriod varchar(100),
	@Arrears numeric(18,2),
	@OldArrears1 numeric(18,2),
	@printed varchar(100),
	@GPSLOC varchar(100) = '',
	@GPSHLOC varchar(100) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here  
	declare @result int
	declare @CustId int
	set @CustId = (Select CustId from Cust where CustNum = @CustNum)
	if(exists(Select * from Rhist where CustId = @CustId and billdate = @BillDate))
	begin
		set @result = 2;
	end
	else
	begin
		
		Insert into Rhist (CustId,BookId,SeqNo,RateId,BillDate,Rdate,Rtime,Pread1,Read1,Cons1,Pread2,Read2,Cons2,
		RangeCd,Tries,MissCd,WarnCd,FF1Cd,FF2Cd,FF3Cd,Remark,nbasic,DueDate,BillPeriod,Arrears,OldArrears1,sept_fee,GPSLOC,GPSHLOC,CreatedDate)
		values(@CustId,(Select BookId from Books where BookNo = @BookNo)
		,@SeqNo,(Select RateId from Rates where RateCd = @Rate),@BillDate,@Rdate,@Rtime,@Pread1,case
		when rtrim(ltrim(@Read1)) = '' then null
		else @Read1 
		end,case
		when @Cons1 = '0.00' then '0'
		when rtrim(ltrim(@Cons1)) = '' then null
		else @Cons1
		end,@Pread2,@Read2,@Cons2,
		@RangeCd,@Tries,@MissCd,@WarnCd,case
		when rtrim(ltrim(@FF1Cd)) = '' then null
		else @FF1Cd
		end,@printed,'0',@Remark,case
		when @Cons1 = '0.00' then '0'
		when rtrim(ltrim(@nbasic)) = '' then null
		when convert(numeric(18,2),rtrim(ltrim(@nbasic))) = '0.00' and 
		(case
		when rtrim(ltrim(@Cons1)) = '' then null
		else @Cons1
		end) = null then null
		else @nbasic
		end,
		@DueDate,
		@BillPeriod,@Arrears,@OldArrears1,0,@gpsloc,@GPSHLOC,GETDATE())

		set @result = 1;
	end
	Select @result as result
END/****** Object:  StoredProcedure [dbo].[sp_breakdownpayment]    Script Date: 08/24/2019 8:03:54 PM ******/
SET ANSI_NULLS ON
