ALTER PROCEDURE [dbo].[sp_passdatabulk]
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
	declare @maxibilldate varchar(7)
	set @maxibilldate = isnull((Select max(billdate) from rhist where CustId = @CustId),convert(varchar(7),getdate(),111))


	Select --Id,
	cBillnum 
	,cBankRef,cCustnum,cBillDate
	,nBillAmnt,cDuedate,cBillDtls
	,cCustname,cBilstAdd,cBilctAdd
	,cBillPeriod,nCurrentBal,withDuedate
	,cDateCreated,cCreatedBy,cBillerCode, convert(int,case when isnull(nCurrentBal,0) <= 0 then 1
	else 0 end) as nStatus
	,MobileNo,Email,Status
	,cDisconnectionDate
	,oldcustnum,meterno1
	,Rate,Zoneno

	from
	(
		Select convert(nvarchar(50),isnull(f.billnum,convert(int,a.Billnum))) as cBillnum
		,convert(nvarchar(20),rtrim(ltrim(a.cbank_ref))) as cBankRef
		,convert(nvarchar(20),a.custnum) as cCustnum
		,isnull(convert(nvarchar(20),b.billdate),convert(varchar(7),getdate(),111)) as cBillDate
		,convert(decimal(18,2),isnull(c.billamnt,isnull([Total Balance],0))) as nBillAmnt
		,isnull(convert(nvarchar(20),convert(datetime,isnull(b.duedate,a.duedate)),111),convert(varchar(20),getdate(),111)) as cDuedate
		,convert(nvarchar(200),isnull(c.Dunning + ' ' + c.billdtls,'')) as cBillDtls
		,convert(nvarchar(100),replace(replace(a.custname,',',''),'''','')) as cCustname
		,convert(nvarchar(200),replace(replace(a.bilstadd,',',''),'''','')) as cBilstAdd
		,convert(nvarchar(200),replace(replace(a.bilctadd,',',''),'''',''))  as cBilctAdd
		,isnull(convert(nvarchar(150),b.billperiod),'') as cBillPeriod
		,convert(decimal(18,2),case when c.billnum is not null then isnull(b.nbasic,0) + (case when ISNULL(end_bal,0) > ISNULL(pn_remit,0) then ISNULL(pn_remit,0) else ISNULL(end_bal,0) end) + (isnull([Total Balance],0) - (isnull(b.nbasic,0) + ISNULL(end_bal,0)))
		else isnull([Total Balance],0) + isnull(b.nbasic,0) end) 
		-- SC Discount when > 30
		/*- case when convert(varchar(20),ISNULL(SeniorDate,'1990-01-01 00:00:00.000'),111) >= convert(varchar(20),getdate(),111)
		and isnull(b.nbasic,0) > 0
		and isnull(b.cons1,0) > 30
		then (759.92 * 0.05)
		when convert(varchar(20),ISNULL(SeniorDate,'1990-01-01 00:00:00.000'),111) >= convert(varchar(20),getdate(),111)
		and isnull(b.nbasic,0) > 0
		and isnull(b.cons1,0) <= 30
		THEN (isnull(b.nbasic,0) * 0.05)
		ELSE 0
		end*/

		--SC Discount when < 30
		- case when convert(varchar(20),ISNULL(SeniorDate,'1990-01-01 00:00:00.000'),111) >= convert(varchar(20),getdate(),111)
		and isnull(b.nbasic,0) > 0
		and isnull(b.cons1,0) <= 30
		then isnull(b.nbasic,0) * 0.05
		else 0.00
		end
		as nCurrentBal
		,convert(int,@withdue) as withDuedate
		,isnull(convert(nvarchar(10),convert(datetime,b.Rdate),111),convert(varchar(20),getdate(),111)) as cDateCreated
		,convert(nvarchar(100),isnull(e.readerid,'')) as cCreatedBy
		,convert(int,@biller) as cBillerCode
		,replace(isnull(a.ccelnumber,''),'''','') MobileNo
		,replace(isnull(a.cemailaddr,''),'''','') Email
		,a.status
		,cDisconnectionDate = convert(varchar(20),isnull(DATEADD(DAY, -2, CONVERT(DATETIME, e.DiscDate)),convert(varchar(20),getdate(),111)),111)
		,a.oldcustnum,f.meterno1
		,q.RateCd as Rate,r.Zoneno
		from cust a
		left join rhist b
		on a.CustId = b.CustId
		and b.billdate = @maxibilldate
		left join cbill c
		on b.RhistId = c.RhistId
		and c.billstat <> 1
		left join vw_ledger d
		on a.CustId = d.CustId
		left join billingschedule e
		on b.BookId = e.BookId
		and b.billdate = e.billdate
		left join Members f
		on a.CustId = f.CustId
		left join PN1 p
		on a.CustId = p.CustId
		and p.end_bal > 1
		LEFT JOIN Rates q
		on a.RateId = q.RateId
		LEFT JOIN Zones r
		on a.ZOneId = r.ZOneId
				
	)result

END

