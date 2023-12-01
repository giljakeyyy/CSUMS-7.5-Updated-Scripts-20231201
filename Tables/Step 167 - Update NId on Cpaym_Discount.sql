--Update NID for Cpaym_Discount
Update 
a
set Nid = b.Nid
FROM
Cpaym_Discount a
Inner Join Cashier_Discount b
on a.nid = b.OldNid