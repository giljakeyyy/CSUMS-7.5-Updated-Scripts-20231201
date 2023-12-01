--Select Insert from Temp Table to New Rates Table
Insert Bill
(
	[RateId], [ZOneId] ,[MinBill], [Cons1],
	[Rate1],[Cons2],[Rate2],[Cons3],[Rate3],
	[Cons4],[Rate4],[Cons5],[Rate5],[minbill2],
	[Cons6],[Rate6],[Cons7],[Rate7]
)
Select [RateId], [ZOneId] ,[MinBill], [Cons1],
	[Rate1],[Cons2],[Rate2],[Cons3],[Rate3],
	[Cons4],[Rate4],[Cons5],[Rate5],[minbill2],
	[Cons6],[Rate6],[Cons7],[Rate7]
From BillTemp
order by [RateId]

--Drop Temp Table
Drop Table BillTemp

--Double Check New Bill
Select * from Bill