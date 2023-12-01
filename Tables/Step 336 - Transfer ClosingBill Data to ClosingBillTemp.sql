--Declare Temporary Table
Create Table ClosingBillTemp
(
	[OldBillNum] int,
	CustId int,
	[RDate] [datetime] NULL,
	[MeterNo1] [varchar](100) NULL,
	[Previous] [int] NULL,
	[LastReading] [int] NULL,
	[Consumption] [int] NULL,
	[Amount1] [money] NULL,
	[Amount2] [money] NULL,
	[Amount3] [money] NULL,
	[Amount4] [money] NULL,
	[Amount5] [money] NULL
);

--Select INsert to Temp Table
Insert ClosingBillTemp
Select a.[BillNum],CustId,[RDate],[MeterNo1],[Previous],
	[LastReading],[Consumption],[Amount1],[Amount2],
	[Amount3] ,[Amount4],[Amount5]
FROM Closing_Bill a
Inner Join Cust b
on a.CustNum = b.CustNum