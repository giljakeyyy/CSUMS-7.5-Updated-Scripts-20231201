ALTER PROCEDURE [dbo].[sp_passbilldetails]
	-- Add the parameters for the stored procedure here
	@CustId int,
	@billercode int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @CustNum1 varchar(20)
	set @CustNum1 = (Select custnum from Cust where CustId = @CustId)
	declare @maxibildate varchar(7)
	declare @JOFees table(ctrid int,appfeetype varchar(20),Appfeename varchar(100),amount money)
	declare @JOTotal money
	insert @JOFees
	exec Cashier_UnpaidApplication @CustNum1,0

	set @JOTotal = isnull((Select sum(amount) from @JOFees),0)

	set @maxibildate = isnull((Select max(billdate) from Rhist where CustId = @CustId),'')
    -- Insert statements for procedure here
	declare @result as table
	(
	[BillNumber] [varchar](50) NOT NULL,
	[Atmref] [varchar](10) NOT NULL,
	[BillingMonth] [varchar](50) NOT NULL,
	[BillingPeriod] [varchar](50) NOT NULL,
	[BasicCharge] [decimal](18, 2) NOT NULL,
	[SeniorDiscount] [decimal](18, 2) NULL,--comment if none
	[TwelvePercentVat] [decimal](18, 2) NULL,--comment if none
	--[LaborDiscount] [decimal](18, 2) NULL,--comment if none
	--[EarlyBirdDiscount] [decimal](18, 2) NULL,--comment if none
	--[NoPressureDiscount] [decimal](18, 2) NULL,--comment if none
	--[FifthyPercentDiscount] [decimal](18, 2) NULL,--comment if none
	--[FivePercentPWDDiscount] [decimal](18, 2) NULL,--comment if none
	--[PromptPaymentDiscount] [decimal](18, 2) NULL,--comment if none
	[TotalCharge] [decimal](18, 2) NULL,
	[Previous] [decimal](18, 2) NOT NULL,
	[PresentReading] [decimal](18, 2) NULL,
	[Usage] [decimal](18, 2) NULL,
	[BalanceFromLastBill] [decimal](18, 2) NULL,
	--[PCA] [decimal](18, 2) NULL,--comment if none
	--[LCA] [decimal](18, 2) NULL,--comment if none
	--[Sewerage] [decimal](18, 2) NULL,--comment if none
	--[MeterCharge] [decimal](18, 2) NULL,--comment if none
	--[DisconnectionFee] [decimal](18, 2) NULL,--comment if none
	--[MeterMaintanceFee] [decimal](18, 2) NULL,--comment if none
	[PromisoryNotes] [decimal](18, 2) NULL,--comment if none
	--[StoppageFee] [decimal](18, 2) NULL,--comment if none
	--[ThreePercentLieuShare] [decimal](18, 2) NULL,--comment if none
	--[Septage] [decimal](18, 2) NULL,--comment if none
	--[EnvironmentalFee] [decimal](18, 2) NULL,--comment if none
	--[GuaranteeDeposit] [decimal](18, 2) NULL,--comment if none
	--[WaterDelivery] [decimal](18, 2) NULL,--comment if none
	--[NotarialFee] [decimal](18, 2) NULL,--comment if none
	--[RoyaltyFee] [decimal](18, 2) NULL,--comment if none
	[WaterDistrictOldArrears] [decimal](18, 2) NULL,--comment if none
	--[FireHydrant] [decimal](18, 2) NULL,--comment if none
	--[ReconnectionFee] [decimal](18, 2) NULL,--comment if none
	--[HOACurrent] [decimal](18, 2) NULL,--comment if none
	--[HOAArrears] [decimal](18, 2) NULL,--comment if none
	--[HOATotal] [decimal](18, 2) NULL,--comment if none
	--[EnviroCurrent] [decimal](18, 2) NULL,--comment if none
	--[EnviroArrears] [decimal](18, 2) NULL,--comment if none
	--[EnviroTotal] [decimal](18, 2) NULL,--comment if none
	[TotalAmountDue] [decimal](18, 2) NOT NULL,
	[MinimumAmountDue] [decimal](18, 2) NOT NULL,
	[AmountAfterDue] [decimal](18, 2) NOT NULL,
	[DueDate] [date] NOT NULL,
	[DisconDate] [date] NOT NULL,
	IsPaid int NULL,
	PaymentMode varchar(50) NULL,
	PaymentDate varchar(50) NULL,
	OtherCharges decimal(18,2) NULL,
	[ResidentialDiscount] [decimal](18, 2) NULL--comment if null
	)

	insert @result
	Select top 2 [BillNumber] = b.billnum,
	[Atmref] = c.cbank_ref,
	[BillingMonth] = a.billdate,
	[BillingPeriod] = isnull(isnull(isnull(a.billperiod,convert(varchar(20),d.fromDate,111) + ' - ' + convert(varchar(20),d.ToDate,111)),e.BillPeriod),convert(varchar(20),getdate(),111) + ' - ' + convert(varchar(20),getdate(),111)),
	[BasicCharge] = CONVERT(MONEY, b.[SubTot1]) -  CONVERT(MONEY, b.[SubTot1] / (0.12 + 1) * 0.12),
	[SeniorDiscount] = CASE WHEN c.SeniorDate >= GETDATE() and a.Cons1 <= 30 THEN CONVERT(DECIMAL(18,2),b.SubTot1 * 0.05) ELSE 0 END,--comment if none/ put conditions
	[TwelvePercentVat] = CONVERT(MONEY, b.[SubTot1] / (0.12 + 1) * 0.12),--comment if none/ put conditions
	--[LaborDiscount] =0.00,--comment if none/ put conditions
	--[EarlyBirdDiscount] =0.00,--comment if none
	--[NoPressureDiscount] =0.00,--comment if none
	--[FifthyPercentDiscount] =0.00,--comment if none
	--[FivePercentPWDDiscount] =0.00,--comment if none
	--[PromptPaymentDiscount] =0.00,--comment if none
	[TotalCharge]  =  b.subtot1 - (CASE WHEN c.SeniorDate >= GETDATE() and a.Cons1 <= 30 THEN CONVERT(DECIMAL(18,2),b.SubTot1 * 0.05) ELSE 0 END) ,
	[Previous] = a.pread1,
	[PresentReading] = a.read1,
	[Usage] = a.cons1,
	[BalanceFromLastBill] = b.subtot4 - ISNULL(end_watfee,0) ,--comment if none
	--[PCA] =0.00,--comment if none
	--[LCA] =0.00,--comment if none
	--[Sewerage] =0.00,--comment if none
	--[MeterCharge] = a.SubTot5,--comment if none
	--[DisconnectionFee] =0.00,--comment if none
	--[MeterMaintanceFee] =0.00,--comment if none
	[PromisoryNotes] = f.pn_remit ,--comment if none
	--[StoppageFee] =0.00,--comment if none
	--[ThreePercentLieuShare] =0.00,--comment if none
	--[Septage] =0.00,--comment if none
	--[EnvironmentalFee] =0.00,--comment if none
	--[GuaranteeDeposit] =0.00,--comment if none
	--[WaterDelivery] =0.00,--comment if none
	--[NotarialFee] =0.00,--comment if none
	--[RoyaltyFee] =0.00,--comment if none
	[WaterDistrictOldArrears] = v.[Old Arrears] - ISNULL(end_procfee,0),--comment if none
	--[FireHydrant] =0.00,--comment if none
	--[ReconnectionFee] =0.00,--comment if none
	--[HOACurrent] =0.00,--comment if none
	--[HOAArrears] =0.00,--comment if none
	--[HOATotal] =0.00,--comment if none
	--[EnviroCurrent] =0.00,--comment if none
	--[EnviroArrears] =0.00,--comment if none
	--[EnviroTotal] =0.00,--comment if none
	[TotalAmountDue] = b.billamnt,
	[MinimumAmountDue] = b.billamnt,
	[AmountAfterDue] = b.billamnt + (b.subtot1 * 0.02),
	[DueDate] = isnull(isnull(b.duedate,c.duedate),convert(varchar(20),getdate(),111)),
	[DisconDate] = isnull(d.discdate,convert(varchar(20),getdate(),111)),
	IsPaid = case
	when isnull(a.IsPaid,0) = 1 then 1
	when isnull(b.BillAmnt,0) <= 0 then 1
	when isnull(b.BillStat,0) = 3 then 1
	when isnull(v.[Total Balance],0) <= 0 and isnull(b.Billstat,0) in(2,3) then 1
	when isnull(g.PaymentDate,'') <> '' then 1
	else 0 
	end,
	PaymentMode = case when isnull(g.PaymentMode,'') <> '' then isnull(g.PaymentMode,'')
	else isnull(g.PaymentMode,'') end,
	PaymentDate = case when isnull(g.PaymentDate,'') <> '' then isnull(g.PaymentDate,'')
	else isnull(g.PaymentDate,'') end,
	OtherCharge = case
	when a.billdate = @maxibildate then @JOTotal
	else 0.00
	end,
	ResidentialDiscount = 0.00--Comment if NULL
	from Rhist a
	LEFT JOIN cbill b
	on a.RhistId = b.RhistId
	INNER JOIN cust c
	on a.CustId = c.CustId
	left join BillingSchedule d
	on a.BillDate = d.BillDate
	and a.BookId = d.BookId
	left join TBill e on
	b.BillNum = e.BillNum
	left join PN1 f on
	c.CustId = f.CustId
	and f.end_bal > 0
	left join vw_ledger v on
	v.CustId = a.CustId
	left join BillsPayment g
	on a.CustId = g.CustId
	and a.billdate = left(g.PaymentDate,7)
	where a.CustId = @CustId
	and a.nbasic > 0
	order by a.billdate desc

	Select * from @result
END