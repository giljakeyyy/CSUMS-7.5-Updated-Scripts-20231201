ALTER PROCEDURE [dbo].[sp_AddReading]
	-- Add the parameters for the stored procedure here
	@CustId int,
	@BookNo varchar(8),
	@SeqNo int,
	@Rate  varchar(2),
	@BillDate varchar(7),
	@Rdate varchar(10),
	@Rtime varchar(5),
	@Pread1 varchar(10),
	@Read1 varchar(10),
	@Cons1 numeric(18,2),
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
	@nbasic numeric(18,2),
	@DueDate varchar(20),
	@BillPeriod varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Insert into Rhist (CustId,BookId,SeqNo,RateId,BillDate,Rdate,Rtime,Pread1,Read1,Cons1,Pread2,Read2,Cons2,
	RangeCd,Tries,MissCd,WarnCd,FF1Cd,FF2Cd,FF3Cd,Remark,nbasic,DueDate,BillPeriod)
	values(@CustId,(Select BookId from Books where BookNo = @BookNo),@SeqNo,(Select RateId from Rates where RateCd = @Rate),@BillDate,@Rdate,@Rtime,@Pread1,@Read1,@Cons1,@Pread2,@Read2,@Cons2,
	@RangeCd,@Tries,@MissCd,@WarnCd,@FF1Cd,@FF2Cd,0,@Remark,@nbasic,@DueDate,@BillPeriod)	
END