ALTER PROCEDURE [dbo].[sp_ViewPNPayments]
	-- Add the parameters for the stored procedure here
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @RunTotalTestData TABLE
	(
		Id int not null identity(1,1) primary key,
		[PN No.] varchar(20),[Date] varchar(14),[Payment No.] varchar(20),
		[OR No.] varchar(20),[Old OR No.] varchar(20),
		Debit money,Credit Money,
		[Reconnection] money,[Water Meter] money,
		[Penalty Fee] money,[Service Deposit] money,[Old Arrears] money,
		[Installation Fee] money,[Technical Cost] money,[Water Arrears] money,
		[Remarks] varchar(50)
	);
 
	DECLARE @RunTotalTestData1 TABLE  
	(
		[PN No.] varchar(20),[Date] varchar(14),[Payment No.] varchar(20),
		[OR No.] varchar(20),[Old OR No.] varchar(20),
		Debit money,Credit Money,
		[Balance] money,
		[Reconnection] money,[Water Meter] money,
		[Penalty Fee] money,[Service Deposit] money,[Old Arrears] money,
		[Installation Fee] money,[Technical Cost] money,[Water Arrears] money,
		[Remarks] varchar(50)
	);
 
	INSERT INTO @RunTotalTestData
	
	Select * from(
	select top 1 '' [PN No.], '' [Date], '' [Payment No.], '' [OR No.], '' [Old OR No.],
	b.beg_bal as Debit,
	0 as Credit,
    0 [Reconnection], 0 [Water Meter], 0 [Penalty Fee], 0 [Service Deposit],
    0 [Old Arrears], 0 [Installation Fee], 0 [Technical Cost], 0 [Water Arrears], 
    '' [Remarks] 
	FROM Cpaym a 
	INNER JOIN Cust
	on a.CustId = Cust.CustId
	INNER JOIN PN1 b 
	on Cust.CustId = b.CustId 
	and a.pnno = b.cpnno
    OUTER APPLY 
	(
		select sum(pn_amount) as [prev_pay] from cpaym where CustId = a.CustId and pnno = a.pnno and paydate < a.paydate
	) c 
    where b.CustId = @CustId and isnull(a.pn_amount, 0) > 0

	UNION

	select a.pnno [PN No.], a.paydate [Date], a.pymntnum [Payment No.], a.ornum [OR No.], a.oldorno [Old OR No.], 
	0 as Debit,
	a.pn_amount as Credit,
    a.rrecfee [Reconnection], a.rwaterm [Water Meter], a.rpenfee [Penalty Fee], a.rservdep [Service Deposit],
    a.rprocfee [Old Arrears], a.rinsfee [Installation Fee], a.rtechfee [Technical Cost], a.rwatfee [Water Arrears], 
    a.pymntdtl [Remarks]
	
	FROM Cpaym a 
	INNER JOIN Cust
	on a.CustId = Cust.CustId
	INNER JOIN PN1 b 
	on Cust.CustId = b.CustId 
	and a.pnno = b.cpnno
    OUTER APPLY
	(
		select sum(pn_amount) as [prev_pay] from cpaym where CustId = a.CustId and pnno = a.pnno and paydate < a.paydate
	) c 
    where b.CustId= @CustId and isnull(a.pn_amount, 0) > 0
	)x order by x.[Date];
	;WITH tempDebitCredit AS (
		SELECT a.id, isnull(a.debit,0) as debit, isnull(a.credit,0) as credit, isnull(a.Debit,0) - isnull(a.Credit,0) 'diff'
		FROM @RunTotalTestData a
	)

	
	
 
 
	INSERT INTO @RunTotalTestData1

	Select 
	ledg2.[PN No.],ledg2.[Date],ledg2.[Payment No.],
			   ledg2.[OR No.],ledg2.[Old OR No.]
			   
				,convert(numeric(18,2),ledg2.debit) as [Debit]
				,convert(numeric(18,2),ledg2.credit) as [Credit]
				,convert(numeric(18,2),isnull(ledg1.Balance,0)) as [Balance]
			   ,ledg2.[Reconnection],ledg2.[Water Meter],
			   ledg2.[Penalty Fee],ledg2.[Service Deposit],ledg2.[Old Arrears],
			   ledg2.[Installation Fee],ledg2.[Technical Cost],ledg2.[Water Arrears],
			   ledg2.[Remarks]
	from(
	SELECT a.id, a.Debit, a.Credit, SUM(b.diff) 'Balance'
	FROM   tempDebitCredit a,
		   tempDebitCredit b
	WHERE b.id <= a.id
	GROUP BY a.id,a.Debit, a.Credit
	)ledg1
	inner join @RunTotalTestData ledg2
	on ledg1.id = ledg2.Id

	order by ledg2.[Date]

	Select 
	ledg2.[PN No.],ledg2.[Date],ledg2.[Payment No.],
			   ledg2.[OR No.],ledg2.[Old OR No.]
			   
				--,convert(numeric(18,2),ledg2.debit) as [Debit]
				,convert(numeric(18,2),ledg2.credit) as Amount
				,[Balance]
			   ,ledg2.[Reconnection],ledg2.[Water Meter],
			   ledg2.[Penalty Fee],ledg2.[Service Deposit],ledg2.[Old Arrears],
			   ledg2.[Installation Fee],ledg2.[Technical Cost],ledg2.[Water Arrears],
			   ledg2.[Remarks] from @RunTotalTestData1 ledg2
	--where [PN No.] <> 'x'
	order by [Date]


END

