ALTER view [dbo].[nostatus] 
as
select * from cust
where cust.CustId not in (select CustId from cbill
	where cbill.billdate = '2003/05' 
	and cust.CustId = cbill.CustId)
