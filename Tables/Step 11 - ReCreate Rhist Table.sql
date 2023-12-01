--Create New Table
CREATE TABLE [dbo].[Rhist](
	[RhistId] int identity(1,1),
	[CustId] int NOT NULL,
	[BookId] int NOT NULL,
	[SeqNo] [int] NULL,
	[RateId] int,
	[BillDate] [varchar](7) NOT NULL,
	[CreatedDate] datetime NOT NULL,
	[Rdate] Date NULL,
	[Rtime] [varchar](15) NULL,
	[Pread1] [varchar](10) NULL,
	[Read1] [varchar](10) NULL,
	[Cons1] [decimal](18, 2) NULL,
	[Pread2] [varchar](10) NULL,
	[Read2] [varchar](10) NULL,
	[Cons2] [decimal](18, 2) NULL,
	[RangeCd] [varchar](1) NULL,
	[Tries] [varchar](1) NULL,
	[MissCd] [varchar](1) NULL,
	[WarnCd] [varchar](1) NULL,
	[FF1Cd] [varchar](2) NULL,
	[FF2Cd] [varchar](2) NULL,
	[FF3Cd] [varchar](2) NULL,
	[Remark] [varchar](50) NULL,
	[nbasic] [money] NULL,
	[DueDate] Date NULL,
	[BillPeriod] [varchar](24) NULL,
	[arrears] [numeric](18, 2) NULL,
	[OldArrears1] [numeric](18, 2) NULL,
	[sept_fee] [money] NULL DEFAULT(0),
	[nrw] [int] NULL,
	[GPSLOC] [varchar](100) NULL,
	[IsPaid] Bit NULL,
	[PaymentMode] [varchar](50) NULL,
	[PaymentDate] Date NULL,
	[GPSHLOC] [varchar](100) NULL,
	 CONSTRAINT [PK_Rhist] PRIMARY KEY NONCLUSTERED 
	(
		RhistId asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	 CONSTRAINT [Unique_Rhist] Unique 
	(
		CustId,BillDate
	)
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId]),
	FOREIGN KEY ([BookId]) REFERENCES Books([BookId]),
	FOREIGN KEY ([RateId]) REFERENCES Rates([RateId])
	) ON [PRIMARY]
