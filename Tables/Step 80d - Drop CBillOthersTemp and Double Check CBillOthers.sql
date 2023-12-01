--Select Insert from Temp Table to New Rhist Table
Insert [CbillOthers]
(
	[BillNum],[CustID],[BillDate],[Payable1],[Amount1],[Payable2],
	[Amount2],[Payable3],[Amount3],[Payable4],[Amount4],
	[Payable5],[Amount5],[Payable6],[Amount6],[Payable7],
	[Amount7],a.[invoice1]
)
Select [BillNum],[CustID],[BillDate],[Payable1],[Amount1],[Payable2],
	[Amount2],[Payable3],[Amount3],[Payable4],[Amount4],
	[Payable5],[Amount5],[Payable6],[Amount6],[Payable7],
	[Amount7],[invoice1]
From CbillOthersTemp
order by [BillNum]

--Drop Temp Table
Drop Table CbillOthersTemp

--Double Check New CbillOthers
Select * from CbillOthers