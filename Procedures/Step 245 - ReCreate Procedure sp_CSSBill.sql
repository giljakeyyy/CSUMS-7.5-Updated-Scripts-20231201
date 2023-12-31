ALTER PROCEDURE [dbo].[sp_CSSBill]
	-- Add the parameters for the stored procedure here
	@Billnum int,
	@Subtot1 numeric(18,2),
	@Subtot4 numeric(18,2),
	@BillAmnt numeric(18,2),
	@Duedate varchar(10),
	@BillDtls varchar(120),
	@Dunning varchar(150),
	@BillPeriod varchar(24),
	@Xuser varchar(100),
	@subtot3 numeric(18,2),
	@subtot5 numeric(18,2),
	@subtot2 numeric(18,2),
	@cmd varchar(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF(@cmd='1')
	BEGIN
		insert into Cbill_Logs 
		(
			Custnum,subtot1,subtot2,subtot3,subtot4,subtot5,BillAmnt,Billdate,Duedate,Dtdate,xuser,commandType
		)
		Select b.Custnum,subtot1,subtot2,subtot3,subtot4,subtot5,BillAmnt,Billdate,a.Duedate,getdate(),@Xuser,'UPDATE' 
		FROM Cbill a
		INNER JOIN Cust b
		on a.CustId = b.CustId
		where a.billnum=@Billnum
	
		Update Cbill set subtot1=@Subtot1,subtot4=@Subtot4,BillAmnt=@BillAmnt,duedate=convert(varchar(10),cast(@Duedate as datetime),111),
		subtot3 = @subtot3,SubTot5 = @subtot5,
		duedate2=convert(varchar(10),cast(@Duedate as datetime),111),BillDtls=@BillDtls,Dunning=@Dunning
		where billnum=@Billnum
		

		update tbill set TotalCharges=@BillAmnt,BillPeriod=@BillPeriod
		where billnum=@Billnum

		update cust_ledger
		set debit = @subtot1
		FROM Cbill a
		Inner Join Cust_Ledger b
		on a.CustId = b.CustId
		and refnum=convert(varchar(100),a.Billnum)
		and transaction_type = 1
		and ledger_type = 'WATER'
		where a.BIllNum = @BIllNum

	END
END
