ALTER PROCEDURE [dbo].[sp_CSSBC_BillPosting]
	-- Add the parameters for the stored procedure here
	@BillNum int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   --update Balance
	Update cust set 
	billnum=b.billnum, DueDate=b.DueDate,DueDate2=b.Duedate2   
	from Cbill a
	INNER JOIN cust b
	on a.CustId = b.CustId
	where a.BillNum = @BillNum

	--insert Water Basic into ledger 

	IF
	(
		NOT EXISTS
		(
			Select Cbill.BillNum from Cbill 
			INNER JOIN Members 
			on CBill.CustId = Members.CustId 
			INNER JOIN books 
			on Members.BookId = Books.BookId 
			where Cbill.BillNum = @BillNum and Books.sharedmonth = CBill.BillDate
		)
	)
	BEGIN
		Insert Into Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
			,transaction_type,previous_reading,reading,consumption,debit,duedate
			,remark,username
		)

		Select a.CustId,getdate(),d.rdate,a.billnum,'WATER',
		a.billdate,1,d.pread1,d.read1,d.cons1,a.subtot1,a.duedate,d.billperiod,e.ReaderID
		FROM cbill a 
		INNER JOIN rhist d
		on a.RhistId = d.RhistId
		INNER JOIN BillingSchedule e
		on d.BookId = e.BookId
		and a.billdate = e.billdate
		where a.BillNum=@BillNum and billstat='1'
				 
	END
	ELSE
	BEGIN
		--Sharing Basic Charge
		Insert Into Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
			,transaction_type,previous_reading,reading,consumption,debit,duedate
			,remark,username
		)
		Select a.CustId,getdate(),d.rdate,a.billnum,'WATER',
		a.billdate,1,d.pread1,d.read1,d.cons1,a.subtot1 * isnull(f.sharing,0),a.duedate,d.billperiod,e.ReaderID
		FROM cbill a 
		INNER JOIN rhist d
		on a.RhistId = d.RhistId
		INNER JOIN BillingSchedule e
		on d.BookId = e.BookId
		and a.billdate = e.billdate
		INNER JOIN Books f
		on d.BookId = f.BookId
		and a.BillDate = f.sharedmonth
		where a.BillNum=@BillNum and billstat='1'
				
			
		--Sharing Old Arrears
		Insert Into Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
			,transaction_type,previous_reading,reading,consumption,debit,duedate
			,remark,username
		)
		Select a.CustId,getdate(),d.rdate,a.billnum,'OLD ARREARS',
		a.billdate,1,d.pread1,d.read1,d.cons1,a.subtot1 - (a.subtot1 * isnull(f.sharing,0))
		,a.duedate,d.billperiod,e.ReaderID
		FROM cbill a 
		INNER JOIN rhist d
		on a.RhistId = d.RhistId
		INNER JOIN BillingSchedule e
		on d.BookId = e.BookId
		and a.billdate = e.billdate
		INNER JOIN Books f
		on d.BookId = f.BookId
		and a.BillDate = f.sharedmonth
		where a.BillNum=@BillNum and billstat='1'

	END
	
	--Insert Into Ledger for MRMF
	Insert Into Cust_Ledger
	(
		CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
		,transaction_type,previous_reading,reading,consumption,debit,duedate
		,remark,username
	)
	Select a.CustId,getdate(),d.rdate,a.billnum,'MRMF',
	a.billdate,1,d.pread1,d.read1,d.cons1,a.subtot5
	,a.duedate,d.billperiod,e.ReaderID
	FROM cbill a 
	INNER JOIN rhist d
	on a.RhistId = d.RhistId
	INNER JOIN BillingSchedule e
	on d.BookId = e.BookId
	and a.billdate = e.billdate
	INNER JOIN Books f
	on d.BookId = f.BookId
	and a.BillDate = f.sharedmonth
	WHERE a.BillNum=@BillNum and billstat='1'

	--Insert Into Ledger for Senior Citizen Discount for a special account (Bacolod)
	Insert Into Cust_Ledger
	(
		CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
		,transaction_type,previous_reading,reading,consumption,Credit,duedate
		,remark,username
	)
	Select a.CustId,getdate(),d.rdate,a.billnum,'Senior Citizen Discount',
	'Senior Discount',3,null,null,null,a.Subtot1 / 2,null,d.billperiod,e.ReaderID
	FROM cbill a 
	INNER JOIN rhist d
	on a.RhistId = d.RhistId
	INNER JOIN BillingSchedule e
	on d.BookId = e.BookId
	and a.billdate = e.billdate
	INNER JOIN Books f
	on d.BookId = f.BookId
	and a.BillDate = f.sharedmonth
	INNER JOIN Cust g
	on a.CustId = g.CustId
	WHERE a.BillNum=@BillNum and billstat='1'
	and g.CustNum ='9349-0120-0036'
			

	--insert Special Discount into ledger (Bacolod)
	Insert Into Cust_Ledger
	(
		CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
		,transaction_type,previous_reading,reading,consumption,Credit,duedate
		,remark,username
	)
	Select a.CustId,getdate(),d.rdate,a.billnum,'WATER',
	a.billdate,3,NULL,NULL,NULL,isnull(a.subtot2,0),'','',''
	FROM cbill a 
	INNER JOIN rhist d
	on a.RhistId = d.RhistId
	INNER JOIN BillingSchedule e
	on d.BookId = e.BookId
	and a.billdate = e.billdate
	INNER JOIN Books f
	on d.BookId = f.BookId
	and a.BillDate = f.sharedmonth
	INNER JOIN Cust g
	on a.CustId = g.CustId
	INNER JOIN Donee_List h
	on g.oldcustnum = h.OldCustNum
	WHERE a.BillNum=@BillNum and billstat='1'
	and ISNULL (a.subtot2,0) > 0.00
	
	
	-- Update status of posted bill
	update cbill set BillStat='2' 
	where BillNum = @BillNum

		


	--update book status
	update Books 
	set bdelvdt =getdate()
	From Cbill
	INNER JOIN Rhist
	on Cbill.RhistId = Cbill.RhistId
	INNER JOIN Books
	on Rhist.BookId = Books.BookId
	where CBill.BillNum = @BillNum
	
END
