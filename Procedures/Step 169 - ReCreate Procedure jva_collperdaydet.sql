ALTER PROCEDURE [dbo].[jva_collperdaydet](
	@from varchar(10),
	@to varchar(10),
	@paymentcenter varchar(max),
	@encoder varchar(20),
	@ptype varchar(10),
	@status varchar(10),
	@due varchar(10),
	@area varchar(10),
	@mode varchar(1),
	@type varchar(1)
)
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Get Modes and Insert to Temp Table
	set @paymentcenter = @paymentcenter + ','
	Declare @PaymentCenterTable as Table(pymntmode int)
	declare @ctr as int
	set @ctr = 1
	declare @Delimit as varchar(100)
	set @Delimit = ''
	while(@ctr <= len(@paymentcenter))
	BEGIN
		if(SUBSTRING(@paymentcenter,@ctr,1) <> ',')
		BEGIN
			set @Delimit = @Delimit + SUBSTRING(@paymentcenter,@ctr,1)
		END
		else
		BEGIN
			Insert @PaymentCenterTable
			Select pymntmode from payment_center
			where cpaycenter = replace(@Delimit,'''','')

			set @Delimit = ''
		END
		set @ctr = @ctr + 1
	END

	--if @Status = 2 then change to 5
	if(@status= '2')
	begin
		set @status='5'
	end


	if(@type = 0)
	begin 
		Select * from
		(
			select a.pymntnum,convert(varchar(20),PayDate,111) [Pymt.Date],ornum [PRIME OR#],case when oldorno <> '' then ISNULL(wdorletter,'') + (CASE WHEN wdorletter <> '' THEN '-' ELSE '' END) + oldorno else oldorno end as [WD OR#]
			,b.custnum [Customer No.],
			custname [Customer Name],cast(payamnt as numeric(18,2)) [Total Payment],isnull(a.pn_amount,0) PN,cast(a.Subtot6 as numeric(18,2)) [Penalty],
			cast(a.Subtot2 as numeric(18,2)) [Arrears],cast(a.Subtot1 as numeric(18,2)) [Water],cast(a.Subtot3 as numeric(18,2)) [Advanced],
			cast(a.subtot9 as numeric(18,2)) [Old Arrears],cast(a.subtot5 as numeric(18,2)) [Deposit],cast(a.Subtot7 as numeric(18,2)) [Service Charge],cast(a.Subtot8 as numeric(18,2)) [Others],
			cast(isnull(a.Subtot12,0) + isnull(a.subtot13,0) + isnull(a.subtot14,0) as numeric(18,2)) [Septage],PymntDtl [Pymt. Det],
			a.RcvdBy [Cashier],d.cpaycenter [Payment Center]

			,convert(numeric(18,2),isnull([Senior-Current],0)) as [Senior-Current]
			,convert(numeric(18,2),isnull([Senior-Arrears],0)) as [Senior-Arrears]
			,convert(numeric(18,2),isnull([WTax-Current],0)) as [Wtax-Current]
			,convert(numeric(18,2),isnull([WTax-Arrears],0)) as [Wtax-Arrears]
			,convert(numeric(18,2),isnull([Early Payment],0)) as [Early Payment]
			,convert(numeric(18,2),isnull([Other Discount],0)) as [Other Discount]
			,0 as [Rebate Discount]
			from
			@PaymentCenterTable paymode
			INNER JOIN 
			cpaym a
			on paymode.pymntmode = a.pymntmode
			INNER JOIN cust b 
			on a.CustId = b.CustId	
			INNER JOIN payment_center d 
			on a.pymntmode = d.pymntmode  
			INNER JOIN Members e 
			on a.CustId =e.CustId
			outer apply(
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,sum(Value)[Senior-Current],
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Senior')
							and Contains( cashier_discount.[description],'Current')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=sum(Value),[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Tax')
							and Contains( cashier_discount.[description],'Current')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = sum(Value),[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Senior')
							and Contains( cashier_discount.[description],'Arrear')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=sum(Value),
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Tax')
							and Contains( cashier_discount.[description],'Arrear')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = sum(Value),[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Early')
							and Contains( cashier_discount.[description],'Payment')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = sum(Value)
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where not( Contains( cashier_discount.[description],'Tax')
							or Contains( cashier_discount.[description],'Senior')
							or Contains( cashier_discount.[description],'Early')
							or Contains( cashier_discount.[description],'Payment')
							)
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
				 )f
			INNER JOIN Books g
			on e.BookId = g.BookId
			INNER JOIN Zones h
			on b.ZoneId = h.ZoneId
			where a.paydate between @from and @to
			--Add RCVDBY QUERY
			and (@encoder = 'ALL' or a.RcvdBy = @encoder)
			--Add pymnttype QUERY
			and (@ptype = '0' or a.pymntTyp = @ptype)
			--Add Status QUERY
			and (@status = '0' or a.pymntstat = @status)
			--Add Area on Query
			and (@mode = '0' or (@mode = '1' and h.ZoneNo = @area) or (@mode <> '0' and @mode <> '1' and g.BookNo = @area))

			UNION

			Select 0,convert(varchar(20),a.trans_date,111),'','',b.custnum,CustName,0
			,0,0,0,0,0,0,0,0,0,0,'','','',0,0,0,0,0,0,sum(isnull(credit,0))
			from cust_ledger a
			left outer join cust b
			on a.CustId = b.CustId
			where credit = 50
			and ledger_type = 'Water'
			and ledger_subtype = 'Billing Rebates'
			and transaction_type = 4
			and remark = 'Billing Rebates'
			and a.username = 'QR Registration'
			and convert(varchar(20),trans_date,111) between @from and @to
			group by b.custnum,b.CustName,trans_date

			UNION ALL

			select max(pymntnum) + 1 pymntnum,'TOTAL OR USED:',
			convert(varchar,sum(totalprimeor)),
			convert(varchar,sum(totaloldor)),
			'','TOTALS',sum([Total Payment]),sum(PN),sum(Penalty),sum([Arrears]),sum([Water]),sum([Advanced]),sum([Old Arrears]),sum([Deposit]),sum([Service Charge]),sum([Others]),sum([Septage]),'Cash: ' + convert(varchar(100),sum(iamcash)),'Check: ' + convert(varchar(100),sum(iamcheck)),''
			,sum([Senior-Current]),sum([Senior-Arrears]),sum([WTax-Current]),sum([Wtax-Arrears]),sum([Early Payment]),sum([Other Discount]),sum([Rebate Discount])
			from(
			select a.pymntnum,PayDate [Pymt.Date],
			case when len(ornum) > 0 then 1 else 0 end as [totalprimeor],
			case when len(oldorno) > 0 then 1 else 0 end as totaloldor,
			b.custnum [Customer No.],
			custname [Customer Name],
			cast(payamnt as numeric(18,2)) [Total Payment],
			isnull(a.pn_amount,0) PN,
			cast(a.Subtot6 as numeric(18,2)) [Penalty],
			cast(a.Subtot2 as numeric(18,2)) [Arrears],
			cast(a.Subtot1 as numeric(18,2)) [Water],
			cast(a.Subtot3 as numeric(18,2)) [Advanced],
			cast(a.subtot9 as numeric(18,2)) [Old Arrears],
			cast(a.subtot5 as numeric(18,2)) [Deposit],
			cast(a.Subtot7 as numeric(18,2)) [Service Charge],	
			cast(a.Subtot8 as numeric(18,2)) [Others],
			cast(a.Subtot12 + isnull(a.subtot13,0) + isnull(a.subtot14,0) as numeric(18,2)) [Septage],
			PymntDtl [Pymt. Det],
			a.RcvdBy [Cashier],d.cpaycenter [Payment Center]
			,iamcash = case when a.pymnttyp = 1
			then 1
			else 0
			end
			,iamcheck = case when a.pymnttyp = 1
			then 0
			else 1
			end
			,convert(numeric(18,2),isnull([Senior-Current],0)) as [Senior-Current]
			,convert(numeric(18,2),isnull([Senior-Arrears],0)) as [Senior-Arrears]
			,convert(numeric(18,2),isnull([WTax-Current],0)) as [Wtax-Current]
			,convert(numeric(18,2),isnull([WTax-Arrears],0)) as [Wtax-Arrears]
			,convert(numeric(18,2),isnull([Early Payment],0)) as [Early Payment]
			,convert(numeric(18,2),isnull([Other Discount],0)) as [Other Discount]
			,0 as [Rebate Discount]
			from 
			@PaymentCenterTable paymode
			INNER JOIN 
			cpaym a
			on paymode.pymntmode = a.pymntmode
			inner join cust b on a.CustId = b.CustId
			inner join payment_center d on a.pymntmode = d.pymntmode
			inner join members e on a.CustId = e.CustId
			outer apply(
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,sum(Value)[Senior-Current],
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Senior')
							and Contains( cashier_discount.[description],'Current')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=sum(Value),[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Tax')
							and Contains( cashier_discount.[description],'Current')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = sum(Value),[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Senior')
							and Contains( cashier_discount.[description],'Arrear')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=sum(Value),
							[Early Payment] = 0.00,[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Tax')
							and Contains( cashier_discount.[description],'Arrear')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = sum(Value),[Other Discount] = 0.00
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where Contains( cashier_discount.[description],'Early')
							and Contains( cashier_discount.[description],'Payment')
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
			
							UNION All
			
							Select isnull(rpymntnum, pymntnum) as pymntnum,[Senior-Current]=0.00,
							[Senior-Arrears] = 0.00,[WTax-Current]=0.00,[WTax-Arrears]=0.00,
							[Early Payment] = 0.00,[Other Discount] = sum(Value)
							from Cpaym_Discount
							inner join cashier_discount
							on Cpaym_Discount.nid = cashier_discount.nid
							where not( Contains( cashier_discount.[description],'Tax')
							or Contains( cashier_discount.[description],'Senior')
							or Contains( cashier_discount.[description],'Early')
							or Contains( cashier_discount.[description],'Payment')
							)
							and pymntnum = isnull(a.rpymntnum, a.pymntnum)
							group by isnull(rpymntnum, pymntnum)
				 )f
			INNER JOIN Books g
			on e.BookId = g.BookId
			INNER JOIN Zones h
			on b.ZoneId = h.ZoneId
			where a.paydate between  @from and @to
			--Add RCVDBY QUERY
			and (@encoder = 'ALL' or a.RcvdBy = @encoder)
			--Add pymnttype QUERY
			and (@ptype = '0' or a.pymntTyp = @ptype)
			--Add Status QUERY
			and (@status = '0' or a.pymntstat = @status)
			--Add Area on Query
			and (@mode = '0' or (@mode = '1' and h.ZoneNo = @area) or (@mode <> '0' and @mode <> '1' and g.BookNo = @area))
			) a 
		)WaterCollection
		ORDER BY [Pymt.Date], pymntnum
	end
	
	ELSE IF(@type=1)
	BEGIN
		
		Select pymntnum,convert(varchar(20),PayDate,111) [Pymt.Date],
		ornum [PRIME OR#],
		custnum [Customer No.],
		cname [Customer Name],
		cast(payamnt as numeric(18,2)) [Total Payment],	
		cast(a.Subtot1 as numeric(18,2)) [Application/JO Fees],
		cast(a.Subtot2 as numeric(18,2)) [Application/JO Others],
		isnull(a.subtot3,0) [Guarantee Deposit],
		isnull(a.tax8,0) [Non-Customer Discount],
		PymntDtl [Pymt. Det],
		a.RcvdBy [Cashier],d.cpaycenter [Payment Center]
		FROM @PaymentCenterTable paymode
		INNER JOIN 
		cpaym2 a
		on paymode.pymntmode = a.pymntmode
		left join payment_center d on a.pymntmode = d.pymntmode
		where a.paydate between @from and @to
		--Add RCVDBY QUERY
		and (@encoder = 'ALL' or a.RcvdBy = @encoder)
		--Add pymnttype QUERY
		and (@ptype = '0' or a.pymntTyp = @ptype)
		--Add Status QUERY
		and (@status = '0' or a.pymntstat = @status)
		
		UNION ALL

		select max(pymntnum) + 1 pymntnum,'TOTAL OR USED:',
		convert(varchar,sum(totalprimeor)),	
		'','TOTALS',sum([Total Payment]),sum([Application/JO Fees]),sum([Application/JO Others]),sum([Guarantee Deposit])
		,sum([Non-Customer Discount]),'','',''
		from
		(
			select pymntnum,PayDate [Pymt.Date],
			case when len(ornum) > 0 then 1 else 0 end as [totalprimeor],	
			custnum [Customer No.],
			cname [Customer Name],
			cast(payamnt as numeric(18,2)) [Total Payment],	
			cast(a.Subtot1 as numeric(18,2)) [Application/JO Fees],
			cast(a.Subtot2 as numeric(18,2)) [Application/JO Others],
			cast(isnull(a.Subtot3,0) as numeric(18,2)) [Guarantee Deposit],
			cast(isnull(a.tax8,0) as numeric(18,2)) [Non-Customer Discount],
			PymntDtl [Pymt. Det],
			a.RcvdBy [Cashier],d.cpaycenter [Payment Center]
			FROM @PaymentCenterTable paymode
			INNER JOIN 
			cpaym2 a
			on paymode.pymntmode = a.pymntmode
			left join payment_center d on a.pymntmode = d.pymntmode
			where a.paydate between @from and @to
			--Add RCVDBY QUERY
			and (@encoder = 'ALL' or a.RcvdBy = @encoder)
			--Add pymnttype QUERY
			and (@ptype = '0' or a.pymntTyp = @ptype)
			--Add Status QUERY
			and (@status = '0' or a.pymntstat = @status)
		) a 
		order by convert(varchar(20),PayDate,111), pymntnum
	END

	ELSE IF(@type = 2)
	BEGIN
		
		SELECT '',convert(varchar(10),a.paydate,111) [Pymt.Date],a.pymntnum [Reference #],c.custnum [Customer No.],
		custname [Customer Name],ratename [Classification],zoneno [ZoneNo.],cast(pn_amount as numeric(18,2)) [Total Payment],
		a.rpenfee [Penalty],a.rservdep [Service Deposit],a.rprocfee [Old Arrears],a.rinsfee [Meter Charge],a.rtechfee [Job Order],a.rwatfee [Water Arrears],
		a.rcvdby [Cashier],d.cpaycenter [Payment Center] 
		from 
		@PaymentCenterTable paymode
		INNER JOIN 
		cpaym a
		on paymode.pymntmode = a.pymntmode
		INNER JOIN cust c on a.CustId = c.CustId	
		INNER JOIN payment_center d on a.pymntmode = d.pymntmode
		INNER JOIN members e on a.CustId =e.CustId
		INNER JOIN rates f on c.RateId = f.RateId
		INNER JOIN Books g
		on e.BookId = g.BookId
		INNER JOIN Zones h
		on c.ZoneId = h.ZoneId
		where isnull(a.pn_amount,0) > 0 and convert(varchar(10),a.paydate,111) between @from and @to
		--Add RCVDBY QUERY
		and (@encoder = 'ALL' or a.RcvdBy = @encoder)
		--Add pymnttype QUERY
		and (@ptype = '0' or a.pymntTyp = @ptype)
		--Add Status QUERY
		and (@status = '0' or a.pymntstat = @status)
		--Add Area on Query
		and (@mode = '0' or (@mode = '1' and h.ZoneNo = @area) or (@mode <> '0' and @mode <> '1' and g.BookNo = @area))
		
		UNION ALL

		select '','',
		convert(varchar,sum(totalprimeor)),	'','TOTALS','','',sum([Total Payment]),sum(rpenfee),sum(rservdep),
		sum(rprocfee),sum(rinsfee),	sum(rtechfee),	sum(rwatfee),'',''
		from
		(
			SELECT convert(varchar(10),a.paydate,111) [Pymt.Date],
			case when len(a.pymntnum) > 0 then 1 else 0 end as [totalprimeor],
			a.pymntnum [Reference #],c.custnum [Customer No.],
			custname [Customer Name],cast(pn_amount as numeric(18,2)) [Total Payment],
			a.rrecfee,a.rwaterm,a.rpenfee,a.rservdep,a.rprocfee,a.rinsfee,a.rtechfee,a.rwatfee,
			a.rcvdby [Cashier],d.cpaycenter [Payment Center] 
			from 
			@PaymentCenterTable paymode
			INNER JOIN 
			cpaym a
			on paymode.pymntmode = a.pymntmode
			INNER JOIN cust c on a.CustId = c.CustId	
			INNER JOIN payment_center d on a.pymntmode = d.pymntmode
			INNER JOIN members e on a.CustId =e.CustId
			INNER JOIN Books g
			on e.BookId = g.BookId
			INNER JOIN Zones h
			on c.ZoneId = h.ZoneId
			where isnull(a.pn_amount,0) > 0 and convert(varchar(10),a.paydate,111) between @from and @to
			--Add RCVDBY QUERY
			and (@encoder = 'ALL' or a.RcvdBy = @encoder)
			--Add pymnttype QUERY
			and (@ptype = '0' or a.pymntTyp = @ptype)
			--Add Status QUERY
			and (@status = '0' or a.pymntstat = @status)
			--Add Area on Query
			and (@mode = '0' or (@mode = '1' and h.ZoneNo = @area) or (@mode <> '0' and @mode <> '1' and g.BookNo = @area))
		) a order by [Pymt.Date] desc
				
	END

	ELSE IF(@type = 3)
	BEGIN

		select pymntnum,convert(varchar(20),PayDate,111) [Pymt.Date],'' [PRIME OR#],oldorno [WD OR#],b.custnum [Customer No.],
		custname [Customer Name],cast(isnull(a.subtot9,0) + isnull(a.rprocfee,0) as numeric(18,2)) [Total Payment],isnull(a.rprocfee,0) PN,0.00 [Penalty],
		0.00 [Arrears],0.00 [Water],0.00 [Advanced],
		cast(a.subtot9 as numeric(18,2)) [Old Arrears],0.00 [Deposit],0.00 [Service Charge],0.00 [Others],
		0.00 [Septage],PymntDtl [Pymt. Det],
		a.RcvdBy [Cashier],d.cpaycenter [Payment Center],b.oldcustnum
		from 
		@PaymentCenterTable paymode
		INNER JOIN 
		cpaym a
		on paymode.pymntmode = a.pymntmode
		INNER JOIN cust b on a.CustId = b.CustId
		INNER JOIN payment_center d on a.pymntmode = d.pymntmode
		INNER JOIN members e on a.CustId =e.CustId
		INNER JOIN Books g
		on e.BookId = g.BookId
		INNER JOIN Zones h
		on b.ZoneId = h.ZoneId
		where isnull(a.subtot9,0) + isnull(a.rprocfee,0) > 0 
		and convert(varchar(20),a.PayDate,111) between @from and @to
		--Add RCVDBY QUERY
		and (@encoder = 'ALL' or a.RcvdBy = @encoder)
		--Add pymnttype QUERY
		and (@ptype = '0' or a.pymntTyp = @ptype)
		--Add Status QUERY
		and (@status = '0' or a.pymntstat = @status)
		--Add Area on Query
		and (@mode = '0' or (@mode = '1' and h.ZoneNo = @area) or (@mode <> '0' and @mode <> '1' and g.BookNo = @area))

		UNION ALL

		select max(pymntnum) + 1 pymntnum,'TOTAL OR USED:',
		convert(varchar,sum(0)),
		convert(varchar,sum(totaloldor)),
		'','TOTALS',sum(isnull([Old Arrears],0) + isnull([PN],0)),sum(isnull([PN],0)),sum(0.00),sum(0.00),sum(0.00),sum(0.00),sum([Old Arrears]),sum(0.00),sum(0.00),sum(0.00),sum(0.00)
		,'','','',''
		from
		(
			select pymntnum,convert(varchar(20),PayDate,111) [Pymt.Date],
			0 as [totalprimeor],
			case when len(oldorno) > 0 then 1 else 0 end as totaloldor,
			b.custnum [Customer No.],
			custname [Customer Name],
			cast(a.subtot9 as numeric(18,2)) [Total Payment],
			isnull(a.rprocfee,0) PN,
			0.00 [Penalty],
			0.00 [Arrears],
			0.00 [Water],
			0.00 [Advanced],
			cast(a.subtot9 as numeric(18,2)) [Old Arrears],
			0.00 [Deposit],
			0.00 [Service Charge],	
			0.00 [Others],
			0.00 [Septage],
			PymntDtl [Pymt. Det],
			a.RcvdBy [Cashier],d.cpaycenter [Payment Center]
			from 
			@PaymentCenterTable paymode
			INNER JOIN 
			cpaym a
			on paymode.pymntmode = a.pymntmode
			INNER JOIN cust b on a.CustId = b.CustId
			INNER JOIN payment_center d on a.pymntmode = d.pymntmode
			INNER JOIN members e on a.CustId =e.CustId
			INNER JOIN Books g
			on e.BookId = g.BookId
			INNER JOIN Zones h
			on b.ZoneId = h.ZoneId
			where isnull(a.subtot9,0) + isnull(a.rprocfee,0) > 0 
			and  convert(varchar(20),a.PayDate,111) between @from and @to
			--Add RCVDBY QUERY
			and (@encoder = 'ALL' or a.RcvdBy = @encoder)
			--Add pymnttype QUERY
			and (@ptype = '0' or a.pymntTyp = @ptype)
			--Add Status QUERY
			and (@status = '0' or a.pymntstat = @status)
			--Add Area on Query
			and (@mode = '0' or (@mode = '1' and h.ZoneNo = @area) or (@mode <> '0' and @mode <> '1' and g.BookNo = @area))
		) a 
		order by convert(varchar(20),PayDate,111), pymntnum
	
	END

	ELSE
	BEGIN
		
		SELECT '',paytype as [Type],convert(varchar(10),a.paydate,111) [Pymt.Date],b.custnum [Customer No.],
		custname [Customer Name],cast(payamnt as numeric(18,2)) [Total Payment],
		a.rcvdby [Cashier],d.cpaycenter [Payment Center],a.ornum as [Prime OR],a.oldorno as [WD OR],deleted_by as [Del By] 
		FROM
		@PaymentCenterTable paymode
		INNER JOIN 
		Cpaym_Cancelled a
		on paymode.pymntmode = a.pymntmode
		LEFT OUTER JOIN cust b on a.CustId = b.CustId
		LEFT OUTER JOIN payment_center d on a.pymntmode = d.pymntmode
		LEFT OUTER JOIN members e on a.CustId =e.CustId
		LEFT OUTER JOIN Books g
		on e.BookId = g.BookId
		where 
		a.paydate between @from and @to
		--Add RCVDBY QUERY
		and (@encoder = 'ALL' or a.RcvdBy = @encoder)

		UNION ALL
		 
			Select 
			'','','',convert(varchar,sum(totalprimeor)),
			'Totals',sum([Total Payment]),
			'','','','',''
			from
			(
			SELECT convert(varchar(10),a.paydate,111) [Pymt.Date],
			case when len(b.custnum) > 0 then 1 else 0 end as [totalprimeor],
			cast(payamnt as numeric(18,2)) [Total Payment] 
			FROM
			@PaymentCenterTable paymode
			INNER JOIN 
			Cpaym_Cancelled a
			on paymode.pymntmode = a.pymntmode
			LEFT OUTER JOIN cust b on a.CustId = b.CustId
			LEFT OUTER JOIN payment_center d on a.pymntmode = d.pymntmode
			LEFT OUTER JOIN members e on a.CustId =e.CustId
			LEFT OUTER JOIN Books g
			on e.BookId = g.BookId
			where 
			a.paydate between @from and @to
			--Add RCVDBY QUERY
			and (@encoder = 'ALL' or a.RcvdBy = @encoder)
		) a 
		order by [Pymt.Date] desc
	
	END

END
