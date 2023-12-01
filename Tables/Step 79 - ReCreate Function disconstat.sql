ALTER FUNCTION [dbo].[disconstat]()
RETURNS TABLE
AS
RETURN
(
    select a.CustId,a.custnum, 
	case
        when (isnull(g.[Water Balance],0))<=isnull(b.minbill,0) then '001' 
        when (isnull(g.[Water Balance], 0) + isnull(g.[Old Arrears], 0) > 0 and isnull(g.[Water Balance], 0) = isnull(d.end_bal,0))then '002'
        when f.first_cons <= 1 then '005'
        when h.RateCd = 'D' or a.cdeveloperid = 'EMP' then '004'
        else space(10) end as type_status
        from cust a inner join
        members x on a.CustId=x.CustId
        left join (select distinct RateId, ZoneId, minbill from bill) b
            on a.RateId = b.RateId and a.ZoneId = b.ZoneId
       
	   left join (select CustId, end_bal from pn1 where end_bal > 0) d
            on a.CustId = d.CustId 
        
		left join (select CustId,count(*) as first_cons from rhist group by CustId) f 
            on a.CustId = f.CustId 
        left join vw_ledger g
            on a.CustId = g.CustId
		left join Rates h
			on a.RateId = h.RateId
)
