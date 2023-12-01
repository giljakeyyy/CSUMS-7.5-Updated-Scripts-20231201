--Select Insert from Temp Table to New Cpaym_Discount Table
Insert Cpaym_Discount
(
	[Pymntnum],[OldPymntnum],[nid],[value],[rpymntnum],
	[ornum]
)
Select 
	[Pymntnum],[OldPymntnum],[nid],[value],[rpymntnum],
	[ornum]
From Cpaym_DiscountTemp
order by [OldPymntnum]

--Drop TempTable
Drop Table Cpaym_DiscountTemp

--Double Check New Cpaym_Discount
Select * from Cpaym_Discount