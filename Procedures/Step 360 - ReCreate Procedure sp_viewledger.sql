ALTER PROCEDURE [dbo].[sp_viewledger]
	-- Add the parameters for the stored procedure here
	@CustId int,
	@ledger_type varchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @RunTotalTestData TABLE  
	(
		Id int not null identity(1,1) primary key,CustId int,posting_date datetime,trans_date datetime,
		refnum varchar(100),ledger_type varchar(100),ledger_subtype varchar(100),
		transaction_type int,previous_reading int,reading int,consumption int,debit money,credit money,duedate datetime
		,remark varchar(150),username varchar(30)
	);
 
	INSERT INTO @RunTotalTestData 
	select CustId, [posting_date], [trans_date], [refnum], [ledger_type], [ledger_subtype], 
	[transaction_type], [previous_reading], [reading], [consumption], [debit], [credit], 
	[duedate], [remark], [username] 
	FROM Cust_Ledger
	where CustId = @CustId
	and ((@ledger_type = 'ALL' and ledger_type <> 'Guarantee Deposit') or (@ledger_type <> 'ALL' and ledger_type = @ledger_type))
	order by convert(varchar(100),trans_date,20),transaction_type;
	;WITH tempDebitCredit AS 
	(
		SELECT a.id, isnull(a.debit,0) as debit, isnull(a.credit,0) as credit, isnull(a.Debit,0) - isnull(a.Credit,0) 'diff'
		FROM @RunTotalTestData a
	)

	Select convert(varchar(100),ledg2.posting_date,0) as [Posting Date]
	,convert(varchar(100),ledg2.trans_date,0) as [Transaction Date]
	,ledg2.refnum as [Ref #]
	,ledg2.ledger_type as [Type]
	,ledg2.ledger_subtype as [SubType]
	,transaction_type.transaction_desc as [Transaction Type]
	,ledg2.previous_reading as [Prev]
	,ledg2.reading as [Pres]
	,ledg2.consumption as Consumption
	,convert(numeric(18,2),ledg2.debit) as [Debit]
	,convert(numeric(18,2),ledg2.credit) as [Credit]
	,convert(numeric(18,2),isnull(ledg1.Balance,0)) as [Balance]
	,convert(varchar(100),ledg2.duedate,111) as [Due Date]
	,ledg2.remark as [Remark]
	,ledg2.username as [Bank/Posted By]
	from(
	SELECT a.id, a.Debit, a.Credit, SUM(b.diff) 'Balance'
	FROM   tempDebitCredit a,
		   tempDebitCredit b
	WHERE b.id <= a.id
	GROUP BY a.id,a.Debit, a.Credit
	)ledg1
	inner join @RunTotalTestData ledg2
	on ledg1.id = ledg2.Id
	left join transaction_type
	on ledg2.transaction_type = transaction_type.transaction_type
	order by convert(varchar(100),ledg2.trans_date,20),ledg2.transaction_type
END
