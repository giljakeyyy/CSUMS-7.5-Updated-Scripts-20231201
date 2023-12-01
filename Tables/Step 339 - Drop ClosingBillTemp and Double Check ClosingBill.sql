--Select Insert from Temp Table to New [ClosingBill] Table
Insert [ClosingBill]
(
	[OldBillNum],CustId,[RDate],[MeterNo1],
	[Previous],[LastReading],[Consumption],
	[Amount1],[Amount2],[Amount3],[Amount4],[Amount5]
)
Select [OldBillNum],CustId,[RDate],[MeterNo1],
	[Previous],[LastReading],[Consumption],
	[Amount1],[Amount2],[Amount3],[Amount4],[Amount5]
From ClosingBillTemp
order by [OldBillNum]

--Drop Temp Table
Drop Table ClosingBillTemp

--Double Check New [ClosingBill]
Select * from [ClosingBill]