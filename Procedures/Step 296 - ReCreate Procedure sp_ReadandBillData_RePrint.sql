ALTER PROCEDURE [dbo].[sp_ReadandBillData_reprint]
	-- Add the parameters for the stored procedure here
	@BookId int,
	@billdate varchar(7)
	,@from as varchar(10)
	,@duedate1 as varchar(10)
	,@duedate2 as varchar(10)
	,@duedate3 as varchar(10)
	,@discondate1 as varchar(10)
	,@discondate2 as varchar(10)
	,@discondate3 as varchar(10)
	,@readerid as varchar(100)
	,@BookId2 int
	,@BookId3 int
	,@BookId4 int
	,@printed int
AS
BEGIN
	
	Declare @billdate1 varchar(7);
	set @billdate1 = (SELECT convert(varchar(7),dateadd(day,-1,@billdate+'/01'),111) AS date)
	declare @last AS varchar(100);
	set @last = left(convert(varchar(100),DATEADD(month, -1, replace(@billdate,'/','-') + '-01'),111),7);
	declare @last1 AS varchar(100);
	set @last1 = left(convert(varchar(100),DATEADD(month, -2, replace(@billdate,'/','-') + '-01'),111),7);
	declare @last2 AS varchar(100);
	set @last2 = left(convert(varchar(100),DATEADD(month, -3, replace(@billdate,'/','-') + '-01'),111),7);
			

	Select 
	RIGHT
	(
		'00000' + convert(varchar(100),ROW_NUMBER() over(order by d.bookno,case
		when isnumeric(a.seqno) = 1 then convert(numeric(18,2),a.seqno)
		else 0 end)),5
	) as sconno
	,b.custnum as accntno,b.custname as name,left(isnull(b.BilStAdd,'') + ' ' + isnull(b.BilCtAdd,''),100) as address
	,e.RateCd as ccode,e.RateName as class,'2' as mcode,a.MeterNo1 as mtrno
	,isnull(xxx.pread1,0) as prevrdg,

	--------------------------------------------------------------------------------------------------------------------------------
	-- || Old Code of Arrears Computation ------------------------------------------------------------------------------------------
			
	case when ((case when (b.SeniorDate>=getdate() and isnull(xxx.arrears,0)<=30 and isnull(xxx.arrears,0)>0)  then  isnull(xxx.arrears,0)- (isnull(xxx.arrears,0)*.05) else isnull(xxx.arrears,0) end) + isnull(vw_ledger.LCA,0) + isnull(vw_ledger.[Old Arrears],0) + isnull(vw_ledger.[SERVICE CHARGE],0) + isnull(vw_ledger.Sewerage,0)) >= (case when (isnull(g.rwatfee,0) + isnull(g.rprocfee,0)) > 0 then isnull(g.end_bal,0) else 0 end)
	then ((case when (b.SeniorDate>=getdate() and isnull(xxx.arrears,0)<=30 and isnull(xxx.arrears,0)>0)  then  isnull(xxx.arrears,0)- (isnull(xxx.arrears,0)*.05) else isnull(xxx.arrears,0) end) + isnull(vw_ledger.LCA,0) + isnull(vw_ledger.[Old Arrears],0) + isnull(vw_ledger.[SERVICE CHARGE],0) + isnull(vw_ledger.Sewerage,0)) - (case when (isnull(g.rwatfee,0) + isnull(g.rprocfee,0)) > 0 then isnull(g.end_bal,0) else 0 end)
	else ((case when (b.SeniorDate>=getdate() and isnull(xxx.arrears,0)<=30 and isnull(xxx.arrears,0)>0)  then  isnull(xxx.arrears,0)- (isnull(xxx.arrears,0)*.05) else isnull(xxx.arrears,0) end) + isnull(vw_ledger.LCA,0) + isnull(vw_ledger.[Old Arrears],0) + isnull(vw_ledger.[SERVICE CHARGE],0) + isnull(vw_ledger.Sewerage,0))
	end as arrears
	,convert(varchar(100),dateadd(day,0,convert(datetime,@from)),111) as prevrdgdate
	,@billdate as billingdate,a.seqno as zoneseq,
	case when b.status = 1 then 'A'
	else 'I' end as [status],isnull(a.AveCon1,0) as avecum,
	case 
	when b.penaltystat = 0
	then 'Y'
	when b.penaltystat = 1
	then 'N'
	else 'Y' end as penstat,'U' as co_activity
	,vw_ledger.[Penalty Balance] as co_penchrge,3 as sumcounter
	,right('00000' + convert(varchar(100),ROW_NUMBER() over(order by d.bookno,case
	when isnumeric(a.seqno) = 1 then convert(numeric(18,2),a.seqno)
	else 0 end)),5) as f_seq
	,1 as evat,'Reconnection Fee' as disc1,0 as out1
	,'Promissory Note Amount' as disc2,(case
	when g.pn_remit <= g.end_bal
	then g.pn_remit
	when g.pn_remit > g.end_bal
	then g.end_bal
	else 0 end) as out2,'Penalty Balance' as disc3,isnull(vw_ledger.[Penalty Balance],0) as out3,
	'MRMF' as disc4,2 as out4
	,'' as disc5,0 as out5,'' as disc6,0 as out6
	-- || -- Bacolod-Specific Conditions -------------------------------------------------------------------------------------------

	,'.JanArrears' as disc7
	,ISNULL(jan_arrears.[JanArrears], 0) as out7

	,'.DueDateExtension' as disc8
	,ISNULL(ddx.[ExtensionDays], 0) as out8

	,'.EmployeeDiscount' as disc9
	,CASE
		WHEN fw.[Type] = 'E'
		THEN
			fw.[Value]
		ELSE
			0
	END AS out9

	,'.OldArrears' as disc10,
	CASE
		WHEN ISNULL(vw_ledger.[Old Arrears], 0) > 0
		THEN
			ISNULL(vw_ledger.[Old Arrears], 0)
		ELSE
			0
	END AS out10

	-- || -- Bacolod-Specific Conditions -------------------------------------------------------------------------------------------

	,d.bookno
	,isnull(h.Cons1,0) as prevcons,rtrim(ltrim(b.cbank_ref))+ right(replace(convert(varchar(10),dateadd(day,-2,convert(datetime,@discondate1)),111),'/',''),4) as atmref,
	b.oldcustnum,case
	when e.RateCd in('') then @duedate2 
	else
	-- || -- Bacolod-Specific Conditions -------------------------------------------------------------------------------------------
		--@duedate1
		CASE
			WHEN ISNULL(ddx.[ExtensionDays], 0) > 0
			THEN
				CONVERT
				(
					VARCHAR(10),
					DATEADD(DAY, ISNULL(ddx.[ExtensionDays], 0), CONVERT(DATETIME, @duedate1)),
					101
				)
			ELSE
				@duedate1
		END
	-- || -- Bacolod-Specific Conditions -------------------------------------------------------------------------------------------
	end as duedate,a.Billnum as billnumber
	,@readerid as readerid,CASE WHEN (convert(varchar(100),b.SeniorDate,111) >= convert(varchar(100),GETDATE(),111)) THEN 1
	WHEN (convert(varchar(100),b.SeniorDate,111) < convert(varchar(100),GETDATE(),111)) THEN 0	
	ELSE 0	END as csstat,case
	when e.RateCd in('') then @discondate2 
	else @discondate1 end discondate
	,case 
	when c.InstallationDate is null then 30
	when DATEDIFF( day , c.InstallationDate , getdate()) >= 15
	then 30
	else DATEDIFF( day , c.InstallationDate , getdate() ) 
	end as noofdays,isnull(vw_ledger.[Guarantee Deposit],0) as gdbal
	,(case 
	when isnull(xxx.arrears,0) < isnull(x.una,0) 
	and isnull(xxx.arrears,0) > 0 then 1
	when isnull(xxx.arrears,0) >= isnull(x.una,0) 
	and isnull(xxx.arrears,0) < isnull(x.una,0) + isnull(y.dalawa,0)
	and isnull(xxx.arrears,0) > 0 then 2
	when isnull(xxx.arrears,0) > isnull(x.una,0) 
	and isnull(xxx.arrears,0) = isnull(x.una,0) + isnull(y.dalawa,0)
	and isnull(xxx.arrears,0) > 0 then 3
	when isnull(xxx.arrears,0) > isnull(x.una,0) 
	and isnull(xxx.arrears,0) > isnull(x.una,0) + isnull(y.dalawa,0)
	and isnull(xxx.arrears,0) > 0 then 4
	else 0 end) + (case when isnull(vw_ledger.[Old Arrears],0) > 0 then 1 else 0 end) as mosarr
			

	,CASE
		WHEN fw.[Type] = 'S'
		THEN
			fw.[Value] * -1
		WHEN
			fw.[Type] = 'P'
		THEN
			fw.[Value]
		ELSE
			0
	END AS [surcharge_basis]

	,isnull(lastcons.lastcons,0) as lastcons
	,isnull(vw_ledger.[Water Balance],0) as prime_arr

	,xxx.Rdate,xxx.Read1,xxx.Cons1,xxx.nbasic,case 
	when xxx.Cons1 >= (isnull(f.average_cons,0) * (case
	when RateGroup.RGDesc = 'Government' or rategroup.RGdesc = 'Residential'
	then 1.5
	else 1.25
	end))
	and xxx.FF3Cd = '0'
	and xxx.FF2Cd = 'UP'
	and xxx.cons1 > 10
	then ''
	else 'FOR PRINTING'
	end as Remark
	,ZOnes.zoneno as BillType

			
	,isnull(consumption12.BillDate,'') as jan
	,isnull(consumption11.BillDate,'') as feb
	,isnull(consumption10.BillDate,'') as mar
	,isnull(consumption9.BillDate,'') as apr
	,isnull(consumption8.BillDate,'') as may
	,isnull(consumption7.BillDate,'') as jun

	,isnull(consumption6.BillDate,'') as jul
	,isnull(consumption5.BillDate,'') as aug
	,isnull(consumption4.BillDate,'') as sep
	,isnull(consumption3.BillDate,'') as oct
	,isnull(consumption2.BillDate,'') as nov
	,isnull(consumption1.BillDate,'') as dec

	,isnull(consumption12.Cons1,0) as jancons
	,isnull(consumption11.Cons1,0) as febcons
	,isnull(consumption10.Cons1,0) as marcons
	,isnull(consumption9.Cons1,0) as aprcons
	,isnull(consumption8.Cons1,0) as maycons
	,isnull(consumption7.Cons1,0) as juncons

	,isnull(consumption6.Cons1,0) as julcons
	,isnull(consumption5.Cons1,0) as augcons
	,isnull(consumption4.Cons1,0) as sepcons
	,isnull(consumption3.Cons1,0) as octcons
	,isnull(consumption2.Cons1,0) as novcons
	,isnull(consumption1.Cons1,0) as deccons
	,case
	when RateGroup.RGDesc = 'Government' or rategroup.RGdesc = 'Residential'
	then 1.5
	else 1.25
	end as [avg_per]
	,isnull(waterdelivery.volume,0) as delivery
	,isnull(xxx.nrw,0) as nrw
	from Members a
	INNER JOIN cust b
	on a.CustId = b.CustId
	INNER JOIN Zones
	on b.ZoneId = Zones.ZoneId
	INNER JOIN Books d
	on a.BookId = d.BookId
	LEFT JOIN Application c
	on b.Applnum = c.ApplNum
	LEFT JOIN Rates e
	on b.RateId = e.RateId
	LEFT JOIN
	(
		Select rhist_1.CustId,convert(numeric(18,0),AVG(cons1)) as average_cons
		FROM Rhist rhist_1
		INNER JOIN
		(
			Select CustId,billdate,row_number() over(partition by CustId order by billdate desc) as ctr from
			rhist where ISNULL(cons1, 0) >= 0 and billdate < @billdate
		)rhist_2
		on rhist_1.CustId = rhist_2.CustId
		and rhist_1.billdate = rhist_2.billdate
		and rhist_1.billdate < @billdate
		and rhist_2.ctr <= 3
		where ISNULL(cons1, 0) >= 0
		group by rhist_1.CustId
	)f
	on a.CustId = f.CustId
	LEFT JOIN
	(
		Select *,ROW_NUMBER() over(partition by CustId order by convert(varchar(100),pn1.dtransd,111)) as ctr
		from pn1 where end_bal > 0
	)g
	on b.CustId = g.CustId
	and g.ctr = 1
	LEFT JOIN rhist h
	on a.CustId = h.CustId
	and h.BillDate = @last
	LEFT JOIN
	(
		Select CustId,subtot1 as una from cbill where billdate = @last
	)x
	on a.CustId = x.CustId
	LEFT JOIN
	(
		Select CustId,subtot1 as dalawa from cbill where billdate = @last1
	)y
	on a.CustId = y.CustId
	LEFT JOIN
	(
		Select CustId,subtot1 as tatlo from cbill where billdate = @last2
	)z
	on a.CustId = z.CustId
	LEFT JOIN
	(
		Select CustId,IDate,IRead,LastCons,ROW_NUMBER() over(partition by CustId order by convert(varchar(100),idate,111)) as ctr 
		FROM CMeters
		where stat = 'I'
	)lastcons
	on a.CustId = lastcons.CustId
	and lastcons.ctr = 1
	and convert(varchar(100),idate,111) between @from and convert(varchar(100),getdate(),111)
	INNER JOIN Rhist xxx
	on a.CustId = xxx.CustId
	and xxx.BillDate = @billdate
	and xxx.nbasic > 0
	and isnumeric(xxx.nbasic) = 1 and convert(numeric(18,2),xxx.nbasic) > 0
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-1,convert(datetime,@billdate + '/01')),111),7)
	)consumption1
	on a.CustId = consumption1.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-2,convert(datetime,@billdate + '/01')),111),7)
	)consumption2
	on a.CustId = consumption2.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-3,convert(datetime,@billdate + '/01')),111),7)
	)consumption3
	on a.CustId = consumption3.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-4,convert(datetime,@billdate + '/01')),111),7)
	)consumption4
	on a.CustId = consumption4.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-5,convert(datetime,@billdate + '/01')),111),7)
	)consumption5
	on a.CustId = consumption5.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-6,convert(datetime,@billdate + '/01')),111),7)
	)consumption6
	on a.CustId = consumption6.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-7,convert(datetime,@billdate + '/01')),111),7)
	)consumption7
	on a.CustId = consumption7.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-8,convert(datetime,@billdate + '/01')),111),7)
	)consumption8
	on a.CustId = consumption8.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-9,convert(datetime,@billdate + '/01')),111),7)
	)consumption9
	on a.CustId = consumption9.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-10,convert(datetime,@billdate + '/01')),111),7)
	)consumption10
	on a.CustId = consumption10.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-11,convert(datetime,@billdate + '/01')),111),7)
	)consumption11
	on a.CustId = consumption11.CustId
	LEFT JOIN
	(
		Select CustId,billdate,cons1
		FROM Rhist 
		WHERE ISNULL(cons1, 0) >= 0
		and billdate = left(convert(varchar(100),dateadd(month,-12,convert(datetime,@billdate + '/01')),111),7)
	)consumption12
	on a.CustId = consumption12.CustId
	LEFT JOIN RateGroup
	on e.rgroupid = RateGroup.RGroupid
	LEFT JOIN vw_ledger
	on a.CustId = vw_ledger.CustId
	LEFT JOIN
	(
		Select custnum,sum(volume) volume from waterdelivery
		where convert(varchar(100),delivery_date,111) >= @from
		group by custnum
	)waterdelivery
	on b.custnum = waterdelivery.custnum

	--------------------------------------------------------------------------------------------------------------------------------
	-- || New Code of Arrears Computation ------------------------------------------------------------------------------------------
	OUTER APPLY
	(
		SELECT
			SUM([Remaining]) - SUM([SeniorDiscount]) AS [Arrears]
		FROM
			[fn_ComputeSeniorBalance](a.CustId)
	) new_balance_senior
	OUTER APPLY
	(
		SELECT
			*
		FROM
			[fn_ComputeCustBalance](a.[CustId], @billdate, 1, 1, 0)
	) new_balance_cust
	--------------------------------------------------------------------------------------------------------------------------------

	-- || -- Bacolod-Specific Conditions -------------------------------------------------------------------------------------------

	LEFT JOIN [Donee_List] fw
		ON b.[oldcustnum] = fw.[OldCustNum]

	LEFT JOIN [DueDateExtension] ddx
		ON b.[oldcustnum] = ddx.[OldCustNum]

	OUTER APPLY
	(
		SELECT
			ISNULL(SUM([debit]), 0) - ISNULL(SUM([credit]), 0) AS [JanArrears]
		FROM
			[cust_ledger]
		WHERE
			CustId = a.CustId
			AND 
			[ledger_type] = 'WATER'
			AND
			(
				[trans_date] IS NULL
				OR
				[trans_date] < '2020/02/01'
			)
	) jan_arrears

	-- || -- Bacolod-Specific Conditions -------------------------------------------------------------------------------------------
			
	WHERE a.BookId in(@BookId,@BookId2,@BookId3,@BookId4)
	and a.CustId = xxx.CustId
	and xxx.BillDate = @billdate
	and xxx.nbasic > 0
	and ((@printed = '0' and xxx.FF2Cd = 'UP') or (@printed <> '0'))
	and isnumeric(xxx.nbasic) = 1 and convert(numeric(18,2),xxx.nbasic) > 0

END