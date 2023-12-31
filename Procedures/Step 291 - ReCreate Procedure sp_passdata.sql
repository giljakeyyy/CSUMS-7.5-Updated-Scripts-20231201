ALTER PROCEDURE [dbo].[sp_passdata]
	-- Add the parameters for the stored procedure here
	@compid varchar(100),
	@withdue varchar(1),
	@biller nvarchar(100),
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Compute Unsubmitted Penalty
	declare @penaltytable table(penaltyamount money)

	insert @penaltytable
	exec sp_cumputeunsubmittedpenalty @CustId

	declare @currpen money

	set @currpen = (select top 1 penaltyamount from @penaltytable)
	
	--Compute Application JO Fees
	declare @CustNum varchar(20)
	set @CustNum = (Select CustNum from Cust where CustId = @CustId)	
	declare @JOFees table(ctrid int,appfeetype varchar(20),Appfeename varchar(100),amount money)
	declare @JOTotal money
	insert @JOFees
	exec Cashier_UnpaidApplication @CustNum,0

	set @JOTotal = isnull((Select sum(amount) from @JOFees),0)
	declare @maxibilldate varchar(7)
	set @maxibilldate = isnull((Select max(billdate) from rhist where CustId = @CustId),convert(varchar(7),getdate(),111))


	Select --Id,
	top 1 cBillnum as BillNumber
	,cBankRef as Atmref,cBillDate as BillDate
	,nBillAmnt as BillAmount,cDuedate as Duedate,cBillDtls as BillDetails
		
	,cBillPeriod as BillPeriod,nCurrentBal as CurrentBalance,withDuedate as WithDuedate
	,cDateCreated as DateCreated,cCreatedBy as CreatedBy
	, convert(int,case when isnull(nCurrentBal,0) <= 0 then 1
	else 0 end) as [Status]
	,cDisconnectionDate as DisconnectionDate
	,nAccountStatus as AccountStatus
	from
	(
		Select convert(nvarchar(50),isnull(f.billnum,convert(int,a.Billnum))) as cBillnum
		,convert(nvarchar(20),rtrim(ltrim(a.cbank_ref))) as cBankRef					
		,convert(nvarchar(20),a.custnum) as cCustnum
		,isnull(convert(nvarchar(20),b.billdate),convert(varchar(7),getdate(),111)) as cBillDate
		,convert(decimal(18,2),isnull(c.billamnt,isnull([Total Balance],0))) as nBillAmnt
		,isnull(convert(nvarchar(20),convert(datetime,isnull(b.duedate,a.duedate)),111),convert(varchar(20),getdate(),111)) as cDuedate
		,convert(nvarchar(200),isnull(c.Dunning + ' ' + c.billdtls,'')) as cBillDtls
		,convert(nvarchar(100),replace(a.custname,',','')) as cCustname
		,convert(nvarchar(200),replace(a.bilstadd,',','')) as cBilstAdd
		,convert(nvarchar(200),replace(a.bilctadd,',',''))  as cBilctAdd
		,isnull(convert(nvarchar(150),b.billperiod),'') as cBillPeriod

		,convert(decimal(18,2),
					
			case when c.billnum is not null then isnull([Total Balance],0)
		else isnull([Total Balance],0) + isnull(b.nbasic,0) end)  
					
		+ 
					
		isnull(@currpen ,0)


		--SC Discount when < 30
		- case when convert(varchar(20),ISNULL(SeniorDate,'1990-01-01 00:00:00.000'),111) >= convert(varchar(20),getdate(),111)
		and isnull(b.nbasic,0) > 0
		and isnull(b.cons1,0) <= 30
		then isnull(b.nbasic,0) * 0.05
		else 0.00
		end
					
		-

		isnull(g.Payments,0.00)

		+ 
		isnull(@JOTotal,0)

		-

		(isnull(h.end_watfee,0) + isnull(h.end_procfee,0) + isnull(h.end_penfee,0))

		+

		isnull(h.pn_remit,0)

		as nCurrentBal

		,convert(int,@withdue) as withDuedate
		,isnull(convert(nvarchar(10),convert(datetime,b.Rdate),111),convert(varchar(20),getdate(),111)) as cDateCreated
		,convert(nvarchar(100),isnull(e.readerid,'')) as cCreatedBy
		,convert(int,@biller) as cBillerCode
		,cDisconnectionDate = convert(varchar(20),isnull(DATEADD(DAY, -2, CONVERT(DATETIME, e.DiscDate)),convert(varchar(20),getdate(),111)),111)
		,a.[Status] as nAccountStatus
		from cust a
		LEFT JOIN rhist b
		on a.CustId = b.CustId
		and b.billdate = @maxibilldate
		LEFT JOIN cbill c
		on b.RhistId = c.RhistId
		and c.billstat <> 1
		LEFT JOIN vw_ledger d
		on a.CustId = d.CustId
		LEFT JOIN billingschedule e
		on b.BookId = e.BookId
		and b.billdate = e.billdate
		LEFT JOIN Members f
		on a.CustId = f.CustId
		LEFT JOIN
		(
			Select CustId,sum(isnull(subtot1,0) + isnull(subtot2,0) + isnull(subtot3,0) + isnull(subtot6,0))Payments 
			FROM Cpaym 
			WHERE CustId = @CustId
			and pymntstat = 1
			and convert(varchar(7),paydate,111) = convert(varchar(7),getdate(),111)
			group by CustId
		)g
		on a.CustId = g.CustId
		LEFT JOIN
		(
			Select CustId,sum(case when end_bal > pn_remit then pn_remit else end_bal end)pn_remit,sum(end_watfee)end_watfee,sum(end_procfee)end_procfee,sum(end_penfee)end_penfee,sum(end_bal)end_bal 
			FROM PN1 where CustId = @CustId and end_bal > 0
			group by CustId
		)h
		on a.CustId = h.CustId
		where a.CustId = @CustId	
	)result

END
