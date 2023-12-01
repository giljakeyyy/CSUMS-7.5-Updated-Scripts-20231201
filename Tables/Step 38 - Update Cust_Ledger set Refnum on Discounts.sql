--Update Refnum on for Discounts on Cust_Ledger
update a 
set refnum = b.[Pymntnum] 
from cust_ledger a
inner join Cpaym b
on a.custId = b.custid
and refnum = convert(varchar(100),b.[OldPymntnum])
and transaction_type = 3
where a.custId = b.custid
and refnum = convert(varchar(100),b.[OldPymntnum])
and transaction_type = 3