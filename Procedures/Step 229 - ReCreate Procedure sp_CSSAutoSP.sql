ALTER PROCEDURE [dbo].[sp_CSSAutoSP] 
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@BookId int,
	@duedate varchar(20)
AS
BEGIN

	DECLARE @CustNum VARCHAR(20)
	SET @CustNum = ''

	SELECT DISTINCT
	b.[BillNum],
	b.CustId,
	@billdate as [BillDate],
	CONVERT(DECIMAL(18, 2), ISNULL(ppp.Penalty * 0.02, 0)) AS [Penalty],
	0 AS PenaltyBalance
	INTO
	##TblPenalty
	FROM
	Cbill b
	left join vw_ledger c on b.CustId = c.CustId
	INNER JOIN Members d
	on b.CustId = d.CustId
	and d.BookId = @BookId
	OUTER APPLY
	(
		SELECT TOP 1 CumulativeRemainingBalance AS [Penalty] FROM [GetArrearsForPenalty](b.CustId) ORDER BY [BillDate] DESC
	) ppp
	where b.BillDate = @billdate
	and ppp.Penalty > 0
	and b.DueDate =@duedate
	

	insert cust_ledger(CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype
	,transaction_type,previous_reading,reading,consumption,debit,credit,duedate
	,remark,username)
	Select a.CustId,getdate(),getdate(),b.billnum,'PENALTY',a.billdate,11,null
	,null,null,isnull(a.Penalty,0),null,null,'Penalty Submission',''
	from ##TblPenalty a 
	INNER JOIN Cust b 
	on a.CustId = b.CustId 
	LEFT JOIN Cust_Ledger c
	on a.CustId = c.CustId
	and c.transaction_type = 11
	and isnumeric(refnum) = 1
	and convert(varchar(20),a.BillNum) = c.refnum
	LEFT JOIN dd_penaltyexemption d
	on b.CustNum = d.CustNum
	and d.BillDate = @billdate
	LEFT JOIN dd_penaltyexemption e
	on b.CustNum = e.CustNum
	and d.[Type] = '1'
	where c.TransId is null
	and d.CustNum is null
	and e.CustNum is null
	
	
	Insert Into CbillOthers 
	(
		BillNum,CustId,BillDate,Amount1,Amount2,invoice1
	)
	Select a.billnum,b.CustId,a.billdate,a.penalty,a.penaltybalance 
	,case when isnull(c.[Penalty Balance],0) >= 0
	then isnull(a.penalty,0)
	else isnull(c.[Penalty Balance],0) + isnull(a.penalty,0)
	end
	from ##TblPenalty a
	INNER JOIN Cust b
	on a.CustId = b.CustId
	left join vw_ledger c
	on a.CustId = c.CustId
	left join(
	Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
	where ledger_type = 'WATER'
	and convert(varchar(100),trans_date,111) <= convert(varchar(100),convert(datetime,@duedate),111)
	group by CustId)water
	on a.CustId = water.CustId
	LEFT JOIN CbillOthers d
	on b.CustId = d.CustId
	and d.billdate = @billdate
	LEFT JOIN dd_penaltyexemption e
	on b.CustNum = e.CustNum
	and e.BillDate = @billdate
	LEFT JOIN dd_penaltyexemption f
	on b.CustNum = f.CustNum
	and f.[Type] = '1'
	where d.CustId is null
	and e.CustNum is null
	and f.CustNum is null

		
END