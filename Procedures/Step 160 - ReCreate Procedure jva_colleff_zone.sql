ALTER PROCEDURE [dbo].[jva_colleff_zone]
	@billdate as varchar(7)
AS
BEGIN
	declare @repdate varchar(7),
		@factor int

	set @repdate = @billdate
	set @factor  = 5  	



	select q.zoneno,q.zonename,isnull(q.applied,0) as applied,isnull(q.moving,0) as moving ,isnull(q.nonmove,0) as nonmove,isnull(q.moving_with_bill,0) as moving_with_bill,
	isnull(q.nmoving_updated,0) as nmoving_updated,isnull(q.moving_all,0) as moving_all ,
			isnull(q.for_discon,0) as for_discon,isnull(q.pv,0) as for_discon_mv_SQL,
			isnull(q.xbillcurrent,0) as xwaterbillcurrent
			
			,isnull(q.xbillwaterdelivery,0) as xbillwaterdelivery
			,isnull(q.xbillcurrent,0) + isnull(q.xbillwaterdelivery,0) as xbillcurrent

			,isnull(q.xbillarrears,0) as xmoving,isnull(q.nonmevebalance,0) as  Nmv_Arr ,isnull(q.total_arrears,0) as total_arrears, isnull(q.total_collectibles,0) as total_collectibles,
			isnull(q.xpcurrent,0) as xpcurrent ,   isnull(q.xpaycurrent1,0) as xpaycurrent1,isnull(q.xpayarrears,0) as xpayarrears, isnull(q.xpayadvance,0) as xpayadvance, isnull(q.xpayothers,0) as xpaywaterdelivery
			,isnull(q.total_payment,0) as total_payment, isnull(q.total_collectibles,0)-isnull(q.total_payment,0) as balance,
			isnull(q.xpayreconfee,0) as xpaydeliverycharge ,isnull(q.xpaydeposit,0) as xpaydeposit, isnull(q.xpayconstruction,0) as xpayconstruction,0 as xpayothers,
		
			cast(isnull(q.eff_current,0) * 100 as decimal(18,2)) as eff_current,
			cast(isnull(q.eff_arrears,0) * 100 as decimal(18,2)) as eff_arrears ,
			cast(isnull(q.up_mv,0) as decimal(18,2)) as up_mv ,
			cast(isnull(q.up_ap,0) as decimal(18,2)) as up_ap ,
			

			q.[Water Bill Cons] as [Water Bill Cons],
			isnull(q.[Water Delivery Cons],0) as [Water Delivery Cons],
			q.totalbillcons,

			cast(isnull(q.ave_cons,0) as decimal(18,2)) as ave_cons,
			isnull(q.OldArrears_move,0) as OldArrears_move,isnull(q.OldArrears_nonmove,0) as OldArrears_nonmove,isnull(q.xpayold_arrears,0) as xpayold_arrears,isnull(q.water_meter_balance_move,0) as water_meter_balance_move,isnull(q.water_meter_balance_nonmove,0) as water_meter_balance_nonmove,isnull(q.pay_water_meter,0) as pay_water_meter 
			
			--dagdag1 
			,convert(numeric(18,2),[Current Year Arrears]) as [Current  Year Arrears]
			,convert(numeric(18,2),[Previous Year Arrears]) as [Previous Year Arrears]
			,convert(numeric(18,2),[Current Year Collection]) as [Current Year Collection]
			,convert(numeric(18,2),[Previous Year Collection]) as [Previous Year Collection]
			,convert(numeric(18,2),[Current Year Efficiency] * 100) as [Current Year Efficiency]
			,convert(numeric(18,2),[Previous Year Efficiency] * 100) as [Previous Year Efficiency]  
			

			from (		
			select a.zoneno,a.zonename,b.applied,c.moving,isnull(d.nonmove,0) as nonmove,h.moving_with_bill,u.nmoving_updated,i.moving_all,
			j.for_discon,j.pv,
			e.xbillcurrent
			,isnull(waterdelivery.totalamount,0) as xbillwaterdelivery
			,e.xbillarrears,dd.nonmevebalance,(isnull(e.xbillarrears,0)+isnull(dd.nonmevebalance,0)) as total_arrears, (isnull(e.xbillarrears,0)+isnull(dd.nonmevebalance,0))+isnull(e.xbillcurrent,0) + isnull(waterdelivery.totalamount,0) as total_collectibles,
			f.xpaycurrent+f.xpayadvance + f.xpayothers as xpcurrent,   f.xpaycurrent as xpaycurrent1,(f.xpayarrears) as xpayarrears , f.xpayadvance
			
			, f.xpayothers

			,(f.xpaycurrent+(f.xpayarrears)+ f.xpayadvance) + f.xpayothers as total_payment, 
			f.xpayreconfee ,f.xpaydeposit, f.xpayconstruction
			, f.xpayproc_fee,
		
			case when isnull(e.xbillcurrent,0)<=0 then 0.00 else case when cast(isnull(e.xbillcurrent,0) + isnull(waterdelivery.totalamount,0) as decimal)>0 then cast((isnull(f.xpaycurrent,0)+isnull(f.xpayadvance,0) + isnull(f.xpayothers,0)) as decimal)/cast(isnull(e.xbillcurrent,0) + isnull(waterdelivery.totalamount,0) as decimal) else 0.00 end end as eff_current,
			case when (isnull(e.xbillarrears,0)+isnull(dd.nonmevebalance,0))<=0 then 0.00 else case when cast((isnull(e.xbillarrears,0)+isnull(dd.nonmevebalance,0)) as decimal) > 0 then cast(isnull(f.xpayarrears,0) as decimal)/cast((isnull(e.xbillarrears,0)+isnull(dd.nonmevebalance,0)) as decimal) else 0.00 end end as eff_arrears,
			case when isnull(c.moving,0)<=0 then 0.00 else case when cast(isnull(c.moving,0) as decimal) > 0 then (cast(isnull(h.moving_with_bill,0) as decimal)/cast(isnull(c.moving,0) as decimal)) else 0.00 end end as up_mv,
			case when isnull(b.applied,0)<=0 then 0.00 else case when cast(isnull(b.applied,0) as decimal) > 0 then cast(isnull(i.moving_all,0) as decimal)/cast(isnull(b.applied,0) as decimal) else 0.00 end end as up_ap,
			l.totalbillcons as [Water Bill Cons],
			isnull(waterdelivery.totalbillcons,0) as [Water Delivery Cons],
			isnull(l.totalbillcons,0) + isnull(waterdelivery.totalbillcons,0) as totalbillcons,
			case when isnull(c.moving,0)<=0 then 0.00 else case when cast(isnull(c.moving,0) as decimal) > 0 then cast(isnull(l.totalbillcons,0) as decimal) /cast(isnull(c.moving,0) as decimal) else 0.00 end end as ave_cons,
			jj.OldArrears_move,ee.OldArrears_nonmove,f.xpayold_arrears,j.balance1_move as water_meter_balance_move,dd.balance1_nonmove as water_meter_balance_nonmove,f.xwater_meter as pay_water_meter
			--dagdag2
			,isnull(yeartodate.CYA,0) as [Current Year Arrears]
			,isnull(yeartodate.PYA,0) as [Previous Year Arrears]
			,isnull(yeartodate.CYC,0) as [Current Year Collection]
			,isnull(yeartodate.PYC,0) as [Previous Year Collection]
			,[Current Year Efficiency] = case 
			when isnull(yeartodate.CYA,0) <= 0 then 0
			else isnull(yeartodate.CYC,0) / isnull(yeartodate.CYA,0)
			end
			,[Previous Year Efficiency] = case 
			when isnull(yeartodate.PYA,0) <= 0 then 0
			else isnull(yeartodate.PYC,0) / isnull(yeartodate.PYA,0)
			end


			from zones a
			left join (select Zoneid,count(*) as applied  from cust group by ZoneId) b
			on a.Zoneid = b.Zoneid
			left join 
			(
				select Zoneid,count(*) as moving  from cust
				INNER JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId
				group by Zoneid
			) c
			on a.Zoneid = c.Zoneid

			left join 
			(
				select Zoneid,count(*) as moving_with_bill  from cust 
				INNER JOIN vw_ledger 
				on cust.CustId = vw_ledger.CustId 
				INNER JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId
				where (isnull([Water Balance],0) <=@factor)
				group by Zoneid
			) h
			on a.Zoneid = h.Zoneid
		
			left join 
			(
				select a.Zoneid,sum(isnull(b.cons1,0)) as totalbillcons  from cust a
				INNER JOIN rhist b
				on a.CustId = b.CustId
				where b.billdate = @repdate
				group by Zoneid
			) l
			on a.Zoneid = l.Zoneid

			
			left join 
			(
				select a.Zoneid,sum(isnull(b.volume,0)) as totalbillcons,sum(isnull(b.amount1,0)) as totalamount 
				from cust a
				INNER JOIN waterdelivery b
				on a.custnum = b.custnum
				where convert(varchar(7),b.delivery_date,111) = @repdate
				group by Zoneid
			) waterdelivery
			on a.ZoneId = waterdelivery.ZoneId


			left join 
			(
				select ZoneId,count(*) as moving_all  from cust 
				INNER JOIN vw_ledger 
				on cust.CustId = vw_ledger.CustId 
				where (isnull(vw_ledger.[Water Balance],0) <=@factor )  group by ZoneId
			) i
			on a.ZoneId = i.ZoneId
		
			left join 
			(
				select ZoneId,count(*) as for_discon,sum([Water Balance]) as pv,sum(isnull([Old Arrears],0)) as OldArrears_move,sum(isnull([Penalty Balance],0)) as balance1_move   
				from cust 
				INNER JOIN vw_ledger 
				on cust.CustId = vw_ledger.CustId 
				INNER JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId
				where [Water Balance] > @factor
				group by ZoneId
			) j
			on a.ZoneId = j.ZoneId
		
			left join 
			(
				select ZoneId,sum(isnull([Old Arrears],0)) as OldArrears_move   
				from cust 
				INNER JOIN vw_ledger 
				on cust.CustId = vw_ledger.CustId
				INNER JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId 
				where [Old Arrears] > @factor
				group by ZoneId
			) jj
			on a.ZoneId = jj.ZoneId

			left join 
			(
				select ZoneId,count (*) as nonmove 
				from cust 
				LEFT JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId 
				where Bills.CustId is null
				group by ZoneId
			) d
			on a.ZoneId = d.ZoneId

			left join 
			(
				select ZoneId,count (*) as nmoving_updated 
				from cust 
				INNER JOIN vw_ledger on cust.CustId = vw_ledger.CustId 
				LEFT JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId 
				where Bills.CustId is null 
				and (isnull([Water Balance],0) <=@factor) 
				group by ZoneId
			) u
			on a.ZoneId = u.ZoneId

			left join 
			(
				select ZoneId,sum(isnull([Water Balance],0)) as nonmevebalance,sum(isnull([Penalty Balance],0)) as balance1_nonmove  
				from cust 
				INNER JOIN vw_ledger on cust.CustId = vw_ledger.CustId 
				LEFT JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId 
				where Bills.CustId is null
				and (isnull([Water Balance],0) > @factor)
				group by ZoneId
			) dd
			on a.ZoneId = dd.ZoneId

			left join 
			(
				select ZoneId,sum(isnull([Old Arrears],0)) as OldArrears_nonmove 
				from cust 
				INNER JOIN vw_ledger on cust.CustId = vw_ledger.CustId 
				LEFT JOIN 
				(
					Select CustId from CBill where billdate = @repdate 
					UNION 
					Select Distinct Cust.CustId from waterdelivery
					INNER JOIN CUST
					on waterdelivery.custnum = waterdelivery.custnum
					where convert(varchar(7),delivery_date,111) = @repdate
				)Bills
				on Cust.CustId = Bills.CustId 
				where Bills.CustId is null
				and (isnull([Old Arrears],0) > @factor)
				group by ZoneId
			) ee
			on a.ZoneId = ee.ZoneId

			left join 
			(
				select a.ZoneId,sum(isnull(b.subtot1,0)) as xbillcurrent,sum(isnull(b.subtot2,0)) as xbillprincescalation,sum(isnull(b.subtot3,0)) as xbillconscost,sum(isnull(b.subtot4,0)) as xbillarrears,sum(isnull(b.subtot5,0)) as xbillreconfee,sum(isnull(b.billamnt,0)) as xbillamnt  
				from cust a 
				INNER JOIN CBill b
				on a.CustId = b.CustId
				and b.BillDate = @repdate
				group by a.ZoneId
			) e
			on a.ZoneId = e.ZoneId

			left join 
			(
				select a.ZoneId,sum(isnull(b.subtot1,0)) as xpaycurrent,sum(isnull(b.subtot2,0)) as xpayarrears, sum(isnull(b.subtot3,0)) as xpayadvance, sum(isnull(b.subtot4,0)) as xpayreconfee,
				sum(isnull(b.subtot5,0)) as xpaydeposit, sum(isnull(b.subtot6,0)) as xpayconstruction, sum(isnull(b.subtot7,0)) as xpayproc_fee, sum(isnull(b.subtot8,0)) as xpayothers, sum(isnull(b.subtot9,0)) as xpayold_arrears,sum(isnull(b.subtot7,0)) as xwater_meter,sum(b.payamnt) as total_paymnt
				from cust a 
				INNER JOIN cpaym b
				on a.CustId = b.CustId 
				and left(b.paydate,7) = @repdate
				where left(b.paydate,7) = @repdate
				group by a.ZoneId
			) f
			on a.ZoneId = f.ZoneId 

			left join 
			(	
				select c.ZoneId,
				sum(a.rwatfee)+sum(a.rprocfee)+sum(a.rinsfee)+sum(a.rrecfee) +sum(isnull(a.rwaterm,0)) +sum(a.rpenfee) +sum(a.rservdep) +sum(a.rtechfee) as total_arears_in_PN 
				from cpaym a 
				INNER JOIN Cust c 
				on a.CustId = c.CustId 
				INNER JOIN zones d 
				on c.ZoneId = d.ZoneId 
				where (convert(varchar(7),a.PayDate,111)=@billdate)
				group by c.ZoneId
			) p
			on a.ZoneId = p.ZoneId
			--dagdag3
		left join
			(
				Select zones.ZoneId,sum(isnull([Current Year Arrears],0)) as [CYA] 
				,sum(isnull([Previous Year Arrears],0)) as [PYA]
				,sum(isnull([CY Collection],0)) as [CYC]
				,sum(isnull([PY Collection],0)) as [PYC]
				from zones
				left join cust
				on zones.ZoneId = cust.ZoneId
				left join
				(
					Select CustId,[Total Payment] = convert(numeric(18,2),[Total Payment] + isnull(Advance,0))
					,convert(numeric(18,2),[Current Year Arrears]) as [Current Year Arrears]
					,convert(numeric(18,2),[Previous Year Arrears]) as [Previous Year Arrears]
					,[CY Collection] = convert(numeric(18,2),isnull([CY Collection],0) + isnull(advance,0)

					+

					(
					case when [Total Payment] > [CY Collection] + [PY Collection]
					then [Total Payment] - [CY Collection] + [PY Collection]
					else 0.00
					end
					)
					)
					,[PY Collection]
					from
					(
						Select cust.CustId,convert(numeric(18,2),isnull(Collected.[Total Payment],0) + isnull(Advance,0)) as [Total Payment]
						,convert(numeric(18,2),ArrearsBreakdown.[Current Year]) as [Current Year Arrears]
						,convert(numeric(18,2),ArrearsBreakdown.[Previous Year]) as [Previous Year Arrears]


						,[CY Collection] = 
						convert(numeric(18,2),
						((
							case
							when isnull([Total Payment],0) <= 0 then 0.00
							when isnull([Total Payment],0) >= 0 
							and isnull([Total Payment],0) <= isnull(ArrearsBreakdown.[Current Year],0) 
							then isnull([Total Payment],0)
							when isnull([Total Payment],0) >= 0 
							and isnull([Total Payment],0) > isnull(ArrearsBreakdown.[Current Year],0) 
							then isnull(ArrearsBreakdown.[Current Year],0)
							else 0.00

							end
						)
						))


						,[PY Collection] = 
						convert(numeric(18,2),
						(
							case
							when isnull([Total Payment],0) - isnull(ArrearsBreakdown.[Current Year],0) <= 0 then 0.00
							when isnull([Total Payment],0) - isnull(ArrearsBreakdown.[Current Year],0) >= 0 
							and isnull(ArrearsBreakdown.[Previous Year],0) > 0
							and isnull([Total Payment],0) - isnull(ArrearsBreakdown.[Current Year],0) <= isnull(ArrearsBreakdown.[Previous Year],0) 
							then isnull([Total Payment],0) - isnull(ArrearsBreakdown.[Current Year],0)
							when isnull([Total Payment],0) - isnull(ArrearsBreakdown.[Current Year],0) >= 0 
							and isnull(ArrearsBreakdown.[Previous Year],0) > 0
							then isnull([Total Payment],0) - isnull(ArrearsBreakdown.[Current Year],0)
							else 0.00

							end
						)
						)

						,[Advance] = isnull(Advance,0)

						from cust

						left join(
						Select CustId,sum(isnull(subtot1,0) + isnull(subtot2,0) + isnull(rwatfee,0)) as [Total Payment]
						,sum(subtot3) as [Advance] 
						from Cpaym
						where convert(varchar(7),paydate,111) = @billdate
						group by CustId
						)Collected
						on cust.CustId = Collected.CustId

						left join
						(

							Select a.CustId,convert(numeric(18,2),isnull(c.SubTot1,0) + isnull(b.Arrears,0)) as [Total Arrears]
							,[Current Year] = convert(numeric(18,2),(case
							when isnull(c.SubTot1,0) + isnull(b.Arrears,0) <= 0 then isnull(c.SubTot1,0) + isnull(b.Arrears,0)
							when isnull(c.SubTot1,0) + isnull(b.Arrears,0) <= isnull(d.[Total Billed],0) then isnull(c.SubTot1,0) + isnull(b.Arrears,0)
							when isnull(c.SubTot1,0) + isnull(b.Arrears,0) > isnull(d.[Total Billed],0) then isnull(d.[Total Billed],0)
							else 0.00
							end
							))

							,[Previous Year] = convert(numeric(18,2),(case
							when isnull(c.SubTot1,0) + isnull(b.Arrears,0) <= 0 then 0.00
							when isnull(c.SubTot1,0) + isnull(b.Arrears,0) <= isnull(d.[Total Billed],0) then 0.00
							when isnull(c.SubTot1,0) + isnull(b.Arrears,0) > isnull(d.[Total Billed],0) then (isnull(c.SubTot1,0) + isnull(b.Arrears,0)) - isnull(d.[Total Billed],0)
							else 0.00
							end
							))
							from cust a
							INNER JOIN
							(
								Select rhist.CustId,sum(isnull(debit,0) - isnull(credit,0)) as arrears 
								from rhist
								INNER JOIN cbill
								on rhist.RhistId = CBill.RhistId
								INNER JOIN cust_ledger
								on rhist.CustId = cust_ledger.CustId
								and cust_ledger.ledger_type = 'WATER'
								and (cust_ledger.trans_date is null or convert(varchar(100),cust_ledger.trans_date,111) < convert(varchar(100),rdate,111))
								where rhist.billdate = @billdate
								group by rhist.CustId

								union

								Select cust.CustId,sum(isnull(debit,0) - isnull(credit,0)) as Arrears
								from cust
						
								INNER JOIN cust_ledger
								on cust.CustId = cust_ledger.CustId
								and cust_ledger.ledger_type = 'WATER'
								and (cust_ledger.trans_date is null or convert(varchar(100),cust_ledger.trans_date,111) < @billdate + '/01')
								LEFT JOIN CBill
								on Cust.CustId = CBill.CustId
								and CBill.BillDate = @billdate
								where CBill.BillNum is null
								group by cust.CustId

							)b
							on a.CustId = b.CustId
							left join cbill c
							on a.CustId = c.CustId
							and c.BillDate = @billdate
							left join
							(
								Select CustId,sum(subtot1) as [Total Billed] from cbill
								where BillDate between left(@billdate,4) + '/01' and @billdate
								and billstat <> 1
								group by CustId
							)d
							on a.CustId = d.CustId
						)ArrearsBreakdown
						on cust.CustId = arrearsBreakdown.CustId
					)CollectionBreakdown
				)CollectionBreakdown
				on cust.CustId = CollectionBreakdown.CustId
				group by zones.ZoneId
		)yeartodate
		on a.ZoneId = yeartodate.ZoneId
			
			) as q

	where (isnull(q.applied,0)+isnull(q.moving,0)+isnull(q.nonmove,0) +isnull(q.moving_with_bill,0) +
	isnull(q.nmoving_updated,0) +isnull(q.moving_all,0)+
			isnull(q.for_discon,0) +isnull(q.pv,0) +
			isnull(q.xbillcurrent,0) +isnull(q.xbillarrears,0) +isnull(q.nonmevebalance,0)+isnull(q.total_arrears,0)+isnull(q.total_collectibles,0)+
 			isnull(q.xpcurrent,0)+isnull(q.xpaycurrent1,0)+isnull(q.xpayarrears,0)+isnull(q.xpayadvance,0)+isnull(q.total_payment,0)+
			isnull(q.xpayreconfee,0)+isnull(q.xpaydeposit,0)+isnull(q.xpayconstruction,0)+isnull(q.xpayproc_fee,0)+isnull(q.xpayothers,0)+
			isnull(q.eff_current,0)+
			isnull(q.eff_arrears,0)+
			isnull(q.up_mv,0)+
			isnull(q.up_ap,0)+
			isnull(q.totalbillcons,0)+
			isnull(q.ave_cons,0)
			) <> 0
	order by q.zoneno
END
