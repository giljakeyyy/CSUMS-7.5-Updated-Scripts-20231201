ALTER PROCEDURE [dbo].[sp_CSSForPenalty]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@BookId int,
	@duedate varchar(20)
AS
BEGIN

	Declare @Mydate datetime
	Declare @temp as int;
	Declare @temp1 as numeric(18,2);
	set @temp=(Select varvalue from variable where varname='PSDatedays')
	set @temp1=(Select varvalue from variable where varname='PSBalance')

	set @Mydate = dateadd(day,@temp,getdate());

	Select distinct a.BillNum,a.CustNum [Customer No.],a.custname [Account Name],a.bilstadd [Bill Street Address],a.balance [Water Arrears],a.DueDate,a.paydate [Last Pay Date],@billdate as BillDate,cast([bbasic] *(0.1) as decimal(18,2)) as ForPenalty,a.balance1 as PenaltyBalance,b.Remark,
	b.refnum as [User]
	FROM
	(
		Select a.billnum,a.CustId,c.CustNum,custname,bilstadd,bilctadd,duedate,paydate,c.RateId,
		[bbasic] =  case when isnull(snamount,0)>0 then  snamount - (snamount * (.05))
		when isnull(balance,0)<=0 then convert(numeric(18,2),isnull(a.subtot1,0)) when  isnull(balance,0)<isnull(a.subtot1,0) then convert(numeric(18,2),isnull(balance,0)) 
		else convert(numeric(18,2),isnull(a.subtot1,0)) end,convert(numeric(18,2),isnull(b.subtot1,0)) as  [pbasic],
		StatDesc,c.bookno,c.BookId,convert(numeric(18,2),balance) as balance,convert(numeric(18,2),balance1) as balance1
		FROM Cbill a 
		LEFT JOIN
		(
			select a.* from cpaym a 
			left join
			(
				select CustId,max(paydate) paydate1 from cpaym where paydate>=@billdate	
				group by CustId
			) b 
			on a.CustId = b.CustId
			where a.paydate = b.paydate1
		)b 
		on a.CustId=b.CustId 		
		LEFT JOIN
		(
			Select a.CustId,a.custnum, isnull(d.[Water Balance],0) as balance,
			isnull(d.[Penalty Balance],0) as balance1,custname,bilstadd,bilctadd,StatDesc,e.BookId,e.BookNo,RateId 
			FROM Cust a 
			LEFT JOIN CustStat b 
			on a.[status]=b.StatCd 
			LEFT JOIN Members c 
			on a.CustId=c.CustId
			LEFT JOIN vw_ledger d
			on a.CustId = d.CustId
			LEFT JOIN
			(
				Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
				where ledger_type = 'WATER'
				and (convert(varchar(100),trans_date,111) <= convert(varchar(100),convert(datetime,@duedate),111) or trans_date is null)
				group by CustId
			)water
			on a.CustId = water.CustId
			LEFT JOIN Books e
			on c.BookId = e.BookId
		) c 
		on a.CustId=c.CustId
		LEFT JOIN
		(
		
			Select convert(varchar(11),a.dtransd,111) as pndate,c.CustId
			FROM PN2 a 
			INNER JOIN PN1  b on a.cpnno=b.cpnno
			INNER JOIN Cust c
			on b.CustId = c.CustId
			where a.cpnno=b.cpnno and  convert(varchar(11),a.dtransd,111)>@billdate
		) d 
		on a.CustId=d.CustId 
		LEFT JOIN
		(
			Select a.CustId,snamount= case when isnull(a.cons1,0)<=10 then  b.minbill
			when isnull(a.cons1,0)>10 and isnull(a.cons1,0)<=20  then  b.minbill + ((a.cons1-10)*rate1) 
			when isnull(a.cons1,0)>20 and isnull(a.cons1,0)<=30  then  b.minbill + (rate1*10) + ((a.cons1-20)*rate2) end
			FROM
			(
				Select Cust.CustId,cons1,Rhist.RateId,Cust.ZoneId from rhist 
				INNER JOIN Cust
				on Rhist.CustId = Cust.CustId
				where billdate=@billdate
			) a
			INNER JOIN Bill b 
			on a.ZoneId = b.ZoneId And a.RateId = b.RateId
		) ee
		on a.CustId=ee.CustId
		WHERE 
		(
			a.billdate=@billdate
			and a.DueDate< Convert(varchar(11),getdate()) and (pndate>duedate)
		) 
		OR 
		(
			a.billdate=@billdate
			and (paydate>a.duedate)
			and a.duedate< Convert(varchar(11),getdate())
		)
		OR 
		(
			balance>0 and a.billdate=@billdate 
			and a.duedate< Convert(varchar(11),getdate())
		)
	) a
	LEFT JOIN
	(
		select Cust.CustId,dd_PenaltyExemption.* from dd_PenaltyExemption
		INNER JOIN Cust
		on dd_PenaltyExemption.CustNum = Cust.CustNum
		where billdate = @billdate
	) b on a.CustId =b.CustId
	LEFT JOIN
	(
		Select CustId,sum(subtot1 + subtot2 + subtot3 + subtot10 + isnull(rwatfee,0)) as paid_unposted 
		FROM Cpaym
		where PymntStat = 1
		and convert(varchar(100),paydate,111) <= @duedate
		group by CustId
	)xxx
	on a.CustId = xxx.CustId
	LEFT JOIN CBillOthers SubmittedPenalty
	on a.CustId = SubmittedPenalty.CUstId
	and SubmittedPenalty.BIllDate = @billdate
	LEFT JOIN 
	(
		Select PN1.* from PN1
		INNER JOIN Cust
		on PN1.CustId = Cust.CustId
		Where PN1.end_watfee <= 0
	)PNBill
	on a.CustId = PNBill.CustId
	WHERE SubmittedPenalty.BillNum is null
	and PNBill.cpnno is null
	and isnull(a.balance,0) - isnull(xxx.paid_unposted,0) > 0
	and a.BookId = @BookId

END
