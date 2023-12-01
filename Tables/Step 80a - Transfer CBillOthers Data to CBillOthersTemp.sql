--Declare Temporary Table
Create Table CbillOthersTemp
(
	[BillNum] [int] NOT NULL,
	[CustID] int NOT NULL,
	[BillDate] varchar(7) NOT NULL,
	[Payable1] [varchar](50) NULL,
	[Amount1] [money] NULL,
	[Payable2] [varchar](50) NULL,
	[Amount2] [money] NULL,
	[Payable3] [varchar](50) NULL,
	[Amount3] [money] NULL,
	[Payable4] [varchar](50) NULL,
	[Amount4] [money] NULL,
	[Payable5] [varchar](50) NULL,
	[Amount5] [money] NULL,
	[Payable6] [varchar](50) NULL,
	[Amount6] [money] NULL,
	[Payable7] [varchar](50) NULL,
	[Amount7] [money] NULL,
	[invoice1] [money] NULL
);

--Select INsert to Temp Table
Insert CbillOthersTemp
Select c.[BillNum],b.[CustID],a.[BillDate],[Payable1],[Amount1],[Payable2],
	[Amount2],[Payable3],[Amount3],[Payable4],[Amount4],
	[Payable5],[Amount5],[Payable6],[Amount6],[Payable7],
	[Amount7],a.[invoice1]
FROM CbillOthers a
Inner Join Cust b
on a.CustNum = b.CustNum
Inner Join Cbill c
on b.CustId = c.CustId
and a.BillDate = c.BillDate