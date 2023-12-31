ALTER PROCEDURE [dbo].[sp_CreateBill]
	-- Add the parameters for the stored procedure here
	@RhistId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
	
	Declare @BillDate varchar(7)
	set @BillDate = isnull((Select BillDate from Rhist where RhistId = @RhistId),'')
	declare @table table (BillNum int primary key)
		
						
	Insert Into Cbill 
	(
		RhistId,CustId,BillDate,CreatedDate,BillStat,BillAmnt,DueDate,Duedate2,BillDtls,RpayNum,Subtot1,SubTot2,SubTot3,SubTot4,SubTot5,Dunning,
		invoice1, invoice2, invoice3, invoice4, invoice5
	)
	OUTPUT Inserted.BillNum into @table(BillNum)
	SELECT a.RhistId,a.CustId,a.BillDate,getdate(),'1',BillAmnt=(isnull(nbasic,0)+isnull(a.arrears,0)) 
	,convert(varchar(11),convert(datetime,a.DueDate),111),convert(varchar(11),convert(datetime,a.DueDate),111),
	'','',isnull(nbasic,0),
	subtot2 = isnull(fw.[Discount], 0) ,
	subtot3 = isnull(a.sept_fee,0)
	,isnull(a.arrears,0),2,'You may pay your bills at Bacolod Water District ',
	0,0,0,0,0
	FROM Rhist a 
	INNER JOIN
	(
		Select CustId,ZoneId,sc_stat = case
		when SeniorDate is not null
		and convert(varchar(100),seniordate,111) <= convert(varchar(100),getdate(),111)
		then 1 else 0 end from cust
	) b 
	on a.CustId=b.CustId 
	INNER JOIN bill c
	on a.RateId = c.RateId and b.ZoneId = c.ZoneId
	INNER JOIN Members f
	on a.CustId = f.CustId
	INNER JOIN rates g
	on a.RateId = g.RateId
	INNER JOIN rategroup h
	on g.rgroupid = h.rgroupid
	INNER JOIN Books i
	on a.BookId = i.BookId
	left join vw_ledger d
	on a.CustId = d.CustId
	LEFT JOIN checkdonee(@Billdate) fw
	on a.CustId = fw.CustId
	LEFT JOIN CBill nobill
	on a.RhistId = nobill.RhistId
	where a.RhistId = @RhistId
	and nobill.BillNum is null
	and (a.nbasic >=0)
	and 
	(
		a.cons1 <= 10
							
		or
		(a.cons1 <= (isnull(f.avecon1,0) * (case when RGDesc = 'Government' or RGdesc = 'Residential' then 1.5
		else 1.25 end)))
		or
		((a.cons1 > (isnull(f.avecon1,0) * (case when RGDesc = 'Government' or RGdesc = 'Residential' then 1.5
		else 1.25 end))) and a.ff3cd = 1)
	)
	and 
	(
		f.AveCon1 <= 10
		or
		(
			a.cons1 >= isnull(f.avecon1,0) - (isnull(f.avecon1,0) * (case when RGDesc = 'Government' or RGdesc = 'Residential' then 0.5
			else 0.25 end))
		)
		or
		(
			(a.cons1 < isnull(f.avecon1,0) - (isnull(f.avecon1,0) * (case when RGDesc = 'Government' or RGdesc = 'Residential' then 0.5
			else 0.25 end))) and a.ff3cd = 1
		)
	)
											
	BEGIN
	
		insert into Tbill (BillNum,CustId,BillDate,BillPeriod,DueDate,
		TotalCharges,MeterNo,RateCd,BillType,MeterInfo1,MeterInfo2,PrevRdg,PresRdg,TotalCons,Cons1,Amount1,Cons2,
		Amount2,Cons3,Amount3,Cons4,Amount4,Cons5,Amount5,AveCons,ConsPerMonth,
		PesoPerDay,cons6,amount6,PenaltyAfter,AmtAfter)
																
		Select 	a.BillNum,b.CustId,b.BillDate,d.BillPeriod,convert(varchar(11),convert(datetime,d.DueDate),111),
		cast(BillAmnt as Varchar(50)),e.MeterNo1,g.RateCd as Rate,'1','','',d.Pread1,d.Read1,rtrim(ltrim(convert(numeric(18),d.Cons1))),'','','',
		'','','','','','','','',rtrim(ltrim(convert(numeric(18),d.Cons1))) + ' cu.m./mon',
		'','','','',''
		from @table a
		INNER JOIN CBill b
		on a.BillNum = b.BillNum
		INNER JOIN Cust c
		on b.CustId = c.CustId
		INNER JOIN Rhist d
		on b.RhistId = d.RhistId
		INNER JOIN Members e
		on b.CustId = e.CustId
		LEFT JOIN TBill f
		on a.BillNum = f.BillNum
		INNER JOIN Rates g
		on c.RateId = g.RateId
		where f.TBillId is null

	END	

END
