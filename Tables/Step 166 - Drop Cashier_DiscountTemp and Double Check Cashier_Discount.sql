--Select Insert from Temp Table to New Cashier_Discount Table
Insert Cashier_Discount
(
	[OldNid],[description],[variable],[discount],
	[vat],[groupid],[destination],[old_vat]
)
Select [OldNid],[description],[variable],[discount],
	[vat],[groupid],[destination],[old_vat]
From Cashier_DiscountTemp
order by [OldNid]

--Drop TempTable
Drop Table Cashier_DiscountTemp

--Double Check New Cbill
Select * from Cashier_Discount