--Create New Table
CREATE TABLE [dbo].[CbillOthers]
(
	[CBillOthersId] int identity(1,1) NOT NULL,
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
	[invoice1] [money] NULL,
	 CONSTRAINT [PK_CbillOthers] PRIMARY KEY NONCLUSTERED 
	(
		[CBillOthersId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId]),
	FOREIGN KEY ([BillNum]) REFERENCES CBill([BillNum])
	) ON [PRIMARY]
