ALTER PROCEDURE [dbo].[sp_breakdownpayment]
-- Add the parameters for the stored procedure here
@custnum varchar(20),
@paydate varchar(20),
@payamnt numeric(18,2)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;


	declare @maxduedate as varchar(100)
	declare @billingdate as varchar(100)
	declare @custnum1 as varchar(50)
	declare @CustId as Int

	set @custnum1 = (Select custnum from cust where 
	replace(CustNum,'-','') = replace(@custnum,'-','') or cbank_ref = @custnum or replace(oldcustnum,'-','') = replace(@custnum,'-',''))
	
	--Get CustId
	set @CustId = (Select CustId from cust where 
	replace(CustNum,'-','') = replace(@custnum,'-','') or cbank_ref = @custnum or replace(oldcustnum,'-','') = replace(@custnum,'-',''))

	if(isnull(@custnum1,'') = '')
	begin
	set @custnum1 = (Select applnum from Application where 
	replace(ApplNum,'-','') = replace(@custnum,'-','') or cbank_ref = @custnum)
	end


	select @billingdate = b.BillDate,@maxduedate = convert(varchar(100),convert(datetime,b.duedate),111)
	from
	(
		Select CustId,max(billdate)billdate from rhist where CustId = @CustId and nbasic > 0 group by CustId
	) a
	inner join Rhist b
	on a.CustId = b.CustId
	and a.billdate = b.BillDate
	where a.CustId = @CustId

	declare @JOMaterials money
	Set @JOMaterials = 0.00
	set @JOMaterials = isnull((
		Select sum(amount) from(
			SELECT
			distinct ctrid,a.appfeetype,Appfeename,amount
			FROM
			[Application_OtherFees] a LEFT JOIN [Applicationfee_type] b ON
			a.[Appfeetype] = b.[Appfeetype]
			LEFT JOIN
			[JobOrderActivity] c ON a.[JobNum] = c.[JobNum]
			WHERE
			a.[Applnum] = @CustNum1
			AND
			ISNULL(a.[Ornum], 0) = 0
			AND
			a.[Amount] > 0
			AND
			ISNULL(c.[Jstatus], 0) != 10
			AND
			@custnum1 != ''
			and b.Appfeename not like '%Guarantee Deposit%'
		)x)
	,0.00)


	declare @JOGDeposit money
	set @JOGDeposit = isnull((
		Select sum(amount) from(
			SELECT
			distinct ctrid,a.appfeetype,Appfeename,amount
			FROM
			[Application_OtherFees] a LEFT JOIN [Applicationfee_type] b ON
			a.[Appfeetype] = b.[Appfeetype]
			LEFT JOIN
			[JobOrderActivity] c ON a.[JobNum] = c.[JobNum]
			WHERE
			a.[Applnum] = @CustNum1
			AND
			ISNULL(a.[Ornum], 0) = 0
			AND
			a.[Amount] > 0
			AND
			ISNULL(c.[Jstatus], 0) != 10
			AND
			@custnum1 != ''
			and b.Appfeename like '%Guarantee Deposit%'
		)x)
	,0.00)


	Select top 1 a.CustId,a.CustNum as [Acct #] 
	,a.CustName as [Name]
	,@paydate as [Paid Date]
	,'' as [Prime OR]
	,'' as [WD OR]
	,@payamnt as [Paid Amount]
	,
	0
	as [For Payment]
	--change balance into [Water Balance]
	,convert(decimal(18, 2), case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0))) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) ))
	else 0 end)
	as [subtot1]

	,convert(decimal(18,2), (case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) - isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	else 0 end) - isnull(d.nwatfee,0)) as [subtot2]
	,0 as [subtot3]
	,0 as [subtot4]
	,0 as [subtot5]
	,convert(decimal(18,2),
	case when (isnull(vw_ledger.[Penalty Balance],0) + (
	case when @paydate > @maxduedate
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and a.CustId not in(Select CustId from CbillOthers where CustId = @CustId and BillDate = @billingdate)
	then isnull((isnull(c.nbasic,0) ),isnull(b.SubTot1,0) - isnull(b.subtot2,0)) * 0.05
	else 0 end
	)
	) > 0 
	then (isnull(vw_ledger.[Penalty Balance],0) + (
	case when @paydate > @maxduedate
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and a.CustId not in(Select CustId from CbillOthers where CustId = @CustId and BillDate = @billingdate)
	then isnull((isnull(c.nbasic,0) ),isnull(b.SubTot1,0) - isnull(b.subtot2,0)) * 0.05
	else 0 end
	)
	)
	else 0 end) as [subtot6]
	,convert(decimal(18,2),
	case when isnull(vw_ledger.[SERVICE CHARGE],0)
	>= 0
	then isnull(vw_ledger.[SERVICE CHARGE],0)
	else 0 end) as [subtot7]
	,0 as [subtot8]
	,convert(decimal(18,2), case
	when isnull(vw_ledger.[Old Arrears],0) <= 0
	then 0
	when isnull(vw_ledger.[Old Arrears],0) >= (case
	when nprocfee > 0 then end_bal else 0 end)
	then isnull(vw_ledger.[Old Arrears],0) - (case
	when nprocfee > 0 then end_bal else 0 end)
	when isnull(vw_ledger.[Old Arrears],0) < (case
	when nprocfee > 0 then end_bal else 0 end)
	and (case
	when nprocfee > 0 then end_bal else 0 end) = 0
	then 0
	else isnull(vw_ledger.[Old Arrears],0) end) as [subtot9]
	,convert(numeric(18,2),case 
	when
	(case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) ))
	else 0 end) > 0
	and @paydate <= convert(varchar(100),a.seniordate,111)
	then (case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) ))
	else 0 end) * 0.05
	else 0 end) as [tax1]

	,convert(numeric(18,2),case
	when @paydate <= convert(varchar(100),a.seniordate,111)
	then((case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0))) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) - isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	else 0 end) - isnull(d.nwatfee,0)) * 0.05
	else 0 end) as tax2

	,convert(numeric(18,2),(convert(numeric(18,2),case 
	when
	(case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) ))
	else 0 end) > 0
	and @paydate <= convert(varchar(100),a.seniordate,111)
	then (case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) ))
	else 0 end) * 0.05
	else 0 end)) + (convert(numeric(18,2),case
	when @paydate <= convert(varchar(100),a.seniordate,111)
	then((case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) - isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0) ))
	else 0 end) - isnull(d.nwatfee,0)) * 0.05
	else 0 end))) as [subtot10]

	,convert(decimal(18,2), case when isnull(vw_ledger.Sewerage,0) + isnull(c.sept_fee,0) > 0
	then isnull(vw_ledger.Sewerage,0) + isnull(c.sept_fee,0)
	else 0 end) as [subtot12]
	,isnull(pn_remit,0) as [PN Amount]
	,isnull(d.rprocfee,0) as [Old PN]
	,isnull(d.rwatfee,0) as [Water PN]
	,isnull(d.rrecfee,0) as [Recon PN]
	,isnull(d.rwaterm,0) as [Meter PN]
	,isnull(d.rpenfee,0) as [Penalty PN]
	,isnull(d.rservdep,0) as [Service Depo PN]
	,isnull(d.rinsfee,0) as [Installation PN]
	,isnull(d.rtechfee,0) as [Technical PN]
	,'Unprocessed' as [CustType]
	,
	[EarlyBirdDiscount] = 

	convert(numeric(18,2),
	case when
	convert(decimal(18, 2), case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0))) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0))) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0)))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0)))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0)))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0)))
	else 0 end) >= 0
	and @paydate <= @maxduedate

	then
	convert(decimal(18, 2), case 
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0))) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0))) >= isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0)))
	then isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0)))
	when
	(isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) > 0
	and (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0) )) < isnull(isnull(b.subtot1,0) - isnull(b.subtot2,0) ,(isnull(c.nbasic,0)))
	then (isnull(vw_ledger.[Water Balance],0) + (isnull(c.nbasic,0)))
	else 0 end)
	* isnull((Select top 1 discount from cashier_discount where description like 'Current Early Payment Discount'),0.00)
	else 0.00
	end
	)

	,JOMaterials = @JOMaterials
	,JOOthers = 0.00
	,JOGDeposit = @JOGDeposit
	into #result
	from 
	(
		Select top 1 CustId,custnum,cbank_ref,custname,BillNum,SeniorDate,ZoneId from cust
		where CustId = @CustId
		union
		Select top 1 0 as CustId,ApplNum as custnum,cbank_ref,ApplName as custname,
		replace(applnum,'-','')billnum,seniordate = null,ZoneId = 0
		from [Application]
		where ApplNum = @custnum1
	) a
	left join cbill b
	on a.CustId = b.CustId
	and a.billnum = b.BillNum
	left join
	(
		Select rhisty.* from
		(
			Select CustId,max(billdate)billdate from Rhist
			where CustId = @CustId
			group by CustId
		)maxy
		INNER JOIN Rhist rhisty
		on maxy.CustId = rhisty.CustId
		and maxy.billdate = rhisty.BillDate
		LEFT JOIN CBill
		on rhisty.RhistId = CBill.RhistId
		where maxy.CustId = rhisty.CustId
		and maxy.billdate = rhisty.BillDate
		and CBill.BillNum is null
	)c
	on a.CustId = c.CustId
	left join
	(
		Select CustId,end_bal,
		rprocfee,
		rwatfee,
		rwaterm,
		rrecfee,
		rservdep,
		rinsfee,
		rtechfee,
		rpenfee,pn_remit,end_procfee as nprocfee,end_watfee as nwatfee
		from pn1 where end_bal > 0
	)d
	on a.CustId = d.CustId
	left join Members e
	on a.CustId = e.CustId
	left join Rhist f
	on a.CustId = f.CustId
	and b.CustId = f.CustId
	and b.BillDate = f.BillDate
	left join bill g
	on c.RateId = g.RateId
	and a.ZoneId = g.ZoneId

	LEFT JOIN dd_OldPenalty
	ON A.CustNum = dd_OldPenalty.CustNum

	LEFT JOIN
	(
		sELECT TOP 1 pn1.CustId,pn1.ddate,pn2.* FROM PN1
		LEFT JOIN PN2
		ON PN1.cpnno = PN2.cpnno
		AND CONVERT(VARCHAR(100),PN2.dtransd,111) BETWEEN CONVERT(VARCHAR(100),DATEADD(month,-1,getdate()),111) and CONVERT(VARCHAR(100),getdate(),111)
		and pn2.rprocfee + pn2.rwatfee > 0
	)PPNN
	on a.CustId = PPNN.CustId
	left join(
	Select * from CbillOthers where CustId = @CustId)cbillothers

	on a.CustId = cbillothers.CustId
	and b.BillDate = cbillothers.BillDate
	left join vw_ledger
	on a.CustId = vw_ledger.CustId
	where (a.CustId = @CustId or a.CustNum = @custnum1)

	IF(ISNULL(@custid,0) = 0 and RTRIM(LTRIM(ISNULL(@custnum1,''))) = '')
	BEGIN
		Select CustId = 0,[Acct #] = '',[Name] = '',[Paid Date] = @paydate
		,[Prime OR] = '',[WD OR] = '',[Paid Amount] = @payamnt
		,[For Payment] = 0.00,[subtot1] = 0.00,[subtot2] = 0.00
		,[subtot3] = 0.00
		,[subtot4] = 0.00,[subtot5] = 0.00
		,[subtot6] = 0.00,[subtot7] = 0.00,[subtot8] = 0.00,[subtot9] = 0.00
		,[tax1] = 0.00,[tax2] = 0.00,[subtot10] = 0.00,[subtot12] = 0.00
		,[PN Amount] = 0.00,[Old PN] = 0.00,[Water PN] = 0.00
		,[Recon PN] = 0.00,[Meter PN] = 0.00,[Penalty PN] = 0.00
		,[Service Depo PN] = 0.00,[Installation PN] = 0.00,[Technical PN] = 0.00,CustType = 'Unprocessed'
		,EarlyBirdDiscount = 0.00
		,JOMaterials = 0.00,JOOthers = 0.00,JOGDeposit = 0.00
	END
	ELSE
	BEGIN
		Select CustId,[Acct #],[Name],[Paid Date]
		,[Prime OR],[WD OR],[Paid Amount]
		,[For Payment],[subtot1],[subtot2]
		,[subtot3] = case
		when convert(numeric(18,2),@payamnt) > convert(numeric(18,2),((subtot1 + subtot2 + subtot3 + subtot4 + subtot5
		+ subtot6 + subtot7 + subtot8 + subtot9 + [subtot12]
		+ [Old PN] + [Water PN] + [Recon PN] + [Meter PN] + [Penalty PN] + [Service Depo PN]
		+ [Installation PN] + [Technical PN] + [JOMaterials] + [JOOthers] + [JOGDeposit]) - (tax1 + tax2 + EarlyBirdDiscount)))
		--and EarlyBirdDiscount > 0
		then convert(numeric(18,2),@payamnt) - convert(numeric(18,2),((subtot1 + subtot2 + subtot3 + subtot4 + subtot5
		+ subtot6 + subtot7 + subtot8 + subtot9 + [subtot12]
		+ [Old PN] + [Water PN] + [Recon PN] + [Meter PN] + [Penalty PN] + [Service Depo PN]
		+ [Installation PN] + [Technical PN]) - (tax1 + tax2 + EarlyBirdDiscount)))
		else 0.00
		end
		,[subtot4],[subtot5]
		,[subtot6],[subtot7],[subtot8],[subtot9]
		,[tax1],[tax2],[subtot10],[subtot12]
		,[PN Amount],[Old PN],[Water PN]
		,[Recon PN],[Meter PN],[Penalty PN]
		,[Service Depo PN],[Installation PN],[Technical PN],CustType
		,EarlyBirdDiscount 
		,JOMaterials,JOOthers,JOGDeposit  from #result
	END
END
