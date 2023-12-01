ALTER VIEW [dbo].[vw_CheckBillForApproval]

AS
Select x.billdate,x.BookId,sum(ForApproval) ForApproval
,sum(Approved)Approved,count(custnum)CTR
from(
	Select a.billdate,a.BookId,f.bookno,ForApproval = case
	when a.ff3cd = 0
	and nbasic > 0
	and (
		((isnull(a.cons1,0) >= (isnull(b.avecon1,0) * (case
		when e.RGDesc = 'Government' or e.RGdesc = 'Residential' then 1.5
		else 1.25 end))) and a.cons1 > 10)
		or
		((isnull(a.cons1,0) <= (isnull(b.avecon1,0) - ((isnull(b.avecon1,0) * (case
		when e.RGDesc = 'Government' or e.RGdesc = 'Residential' then 0.5
		else 0.25 end)))) and b.AveCon1 > 10)
		)
	)
	and isnull(a.remark,'') <> ''
	then
	1
	else 0
	end
	,
	Approved = convert(int,ISNULL(a.[FF3Cd], 0)),c.custnum 

	from rhist a
	INNER JOIN Members b
	on a.CustId = b.CustId
	INNER JOIN Cust c
	on a.CustId = c.CustId
	INNER JOIN Rates d
	on c.RateId = d.RateId
	INNER JOIN RateGroup e
	on d.rgroupid = e.rgroupid
	INNER JOIN Books f
	on a.BookId = f.BookId
	where a.nbasic > 0
)x
group by x.billdate,x.BookId

