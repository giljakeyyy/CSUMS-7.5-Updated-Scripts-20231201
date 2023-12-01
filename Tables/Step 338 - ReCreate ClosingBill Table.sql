--Create New Table
CREATE TABLE [dbo].[ClosingBill]
(
	[BillNum] int identity(1,1),
	[OldBillNum] int,
	CustId int,
	[RDate] Date NULL,
	[MeterNo1] [varchar](100) NULL,
	[Previous] [int] NULL,
	[LastReading] [int] NULL,
	[Consumption] [int] NULL,
	[Amount1] [money] NULL,
	[Amount2] [money] NULL,
	[Amount3] [money] NULL,
	[Amount4] [money] NULL,
	[Amount5] [money] NULL,
	 CONSTRAINT [PK_ClosingBill] PRIMARY KEY NONCLUSTERED 
	(
		[BillNum] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
	) ON [PRIMARY]
