ALTER PROCEDURE [dbo].[sp_CSSReadDel]
	@RhistId int,
	@xuser varchar(100),
	@reason varchar(200)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @BillNum int
	Set @BillNum = (Select BillNum from Cbill where RhistId = @RhistId)
	declare @CustId int
	Set @CustId = (Select CustId from Cbill where RhistId = @RhistId)

	Insert into rhist_logs 
	(
		Custnum,Billdate,readdate,Pread1,Read1,Cons,Remarks,DtDate,Xuser,Commandtype
	)
	Select Cust.CustNum,Billdate,Rdate,Pread1,Read1,Cons1,Remark,GETDATE(),@xuser,'DELETE' 
	FROM Rhist
	INNER JOIN Cust
	on Rhist.CustId = Cust.CustId
	where RhistId = @RhistId
	
	insert into Cbill_Logs 
	(
		Custnum,subtot1,subtot2,subtot3,subtot4,subtot5,BillAmnt,Billdate,Duedate,Dtdate,xuser,commandType
	)
	Select Custnum,subtot1,subtot2,subtot3,subtot4,subtot5,BillAmnt,Billdate,Cbill.Duedate,getdate(),@Xuser,'DELETE'
	FROM Cbill
	INNER JOIN Cust
	on Cbill.CustId = Cust.CustId
	where RhistId = @RhistId
	
	
	declare @date varchar(20)
	declare @date1 varchar(20)
	set @date = (Select BillDate from Rhist where RhistId = @RhistId) + '/01'

	set @date1 = isnull((Select dbo.correct_paydate(@date) as paydate),'')

	IF(@date = @date1)
	BEGIN
		--Deleting Columns on Tables
		Delete cbillothers
		from cbillothers
		INNER JOIN Cbill
		on cbillothers.BillNum = CBill.BillNum
		where Cbill.RhistId = @RhistId

		Delete tbill
		from tbill
		INNER JOIN Cbill
		on TBill.BillNum = CBill.BillNum
		where Cbill.RhistId = @RhistId

		Delete from cbill where RhistId = @RhistId

		delete from rhist where RhistId = @RhistId


		--Reversal on Ledger
		
		insert cust_ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit
			,credit,remark,username
		)

		Select CustId,getdate(),GETDATE(),refnum,ledger_type,'ADJ',12,null
		,debit,'Billing Rollback - ' + @reason,@xuser
		from cust_ledger
		where (transaction_type = 1 or transaction_type = 11)
		and refnum = Convert(Varchar(20),@billnum)
		and CustId = @CustId

		--DISCOUNT
		insert cust_ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit
			,credit,remark,username
		)

		Select CustId,getdate(),GETDATE(),refnum,ledger_type,'ADJ',12,credit
		,null,'Billing Rollback - ' + @reason,@xuser
		from cust_ledger
		where (transaction_type = 3)
		and refnum = Convert(Varchar(20),@billnum)
		and CustId = @CustId

	END

	ELSE IF(@date <> @date1)
	BEGIN
		insert cust_ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit
			,credit,remark,username
		)

		Select CustId,getdate(),GETDATE(),refnum,ledger_type,'ADJ',12,null
		,debit,'Billing Rollback - ' + @reason,@xuser
		from cust_ledger
		where (transaction_type = 1 or transaction_type = 11)
		and refnum = Convert(Varchar(20),@billnum)
		and CustId = @CustId

		--DISCOUNT
		insert cust_ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit
			,credit,remark,username
		)

		Select CustId,getdate(),GETDATE(),refnum,ledger_type,'ADJ',12,credit
		,null,'Billing Rollback - ' + @reason,@xuser
		from cust_ledger
		where (transaction_type = 3)
		and refnum = Convert(Varchar(20),@billnum)
		and CustId = @CustId

		update cbill
		set isLateCancelled = 1
		where RhistId = @RhistId

	END
END
