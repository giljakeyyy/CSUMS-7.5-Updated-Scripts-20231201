--Update BillNum on Cust from CBill
Update a
set BillNum = b.Billnum
from Cust a
inner join(Select CustId,max(Billnum) BillNum from Cbill group by CustId)b
on a.CustId = b.CustId
