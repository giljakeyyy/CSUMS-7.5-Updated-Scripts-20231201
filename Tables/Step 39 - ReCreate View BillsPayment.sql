ALTER VIEW [dbo].[BillsPayment]
AS

Select w.CustId,w.custnum,convert(varchar(20),y.paydate,111)PaymentDate,z.cpaycenter as PaymentMode 
from Cust w
inner join
(
SELECT CustId,convert(varchar(7),Paydate,111)PayDate,max(pymntnum)pymntnum from Cpaym
group by CustId,convert(varchar(7),Paydate,111)
)x
on w.CustId = x.CustId
inner join cpaym y
on x.pymntnum = y.PymntNum
inner join payment_center z
on y.PymntMode = z.pymntmode


