ALTER view [dbo].[unbilled]
as
select zoneno, zonename, unbilledactive = (select count(*)  from cust
				where cust.ZoneId = zones.ZoneId
				and cust.status = '1' 
				and cust.CustId not in (select CustId from cbill
							where cbill.billdate = '2003/08' 
							and cust.CustId = cbill.CustId)),
			unbilledinactive = (select count(*)  from cust
				where cust.ZoneId = zones.ZoneId
				and cust.status= '2' 
				and cust.CustId not in (select CustId from cbill
							where cbill.billdate = '2003/08' 
							and cust.CustId = cbill.CustId)),
			unbilleddisconn = (select count(*)  from cust
				where cust.ZoneId = zones.ZoneId
				and cust.status= '3' 
				and cust.CustId not in (select CustId from cbill
							where cbill.billdate = '2003/08' 
							and cust.CustId = cbill.CustId)),
			unbilledillegal = (select count(*)  from cust
				where cust.ZoneId = zones.ZoneId
				and cust.status= '4' 
				and cust.CustId not in (select CustId from cbill
							where cbill.billdate = '2003/08' 
							and cust.CustId = cbill.CustId)),
			unbillednostatus = (select count(*)  from cust
				where cust.ZoneId = zones.ZoneId
				and cust.status= '' 
				and cust.CustId not in (select CustId from cbill
							where cbill.billdate = '2003/08' 
							and cust.CustId = cbill.CustId))


from zones 

