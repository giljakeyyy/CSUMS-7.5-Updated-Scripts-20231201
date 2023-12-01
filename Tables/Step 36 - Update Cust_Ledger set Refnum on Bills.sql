--Update Refnum on for Bills on Cust_Ledger
update a 
set refnum = b.Billnum 
from cust_ledger a
inner join Cbill b
on a.custId = b.custid
and ledger_subtype = b.billdate
and transaction_type = 1
where transaction_type = 1
and ledger_subtype = b.billdate