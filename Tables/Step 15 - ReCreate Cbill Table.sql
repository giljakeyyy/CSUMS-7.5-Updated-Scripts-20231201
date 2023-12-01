--Recreate Cbill
CREATE TABLE [dbo].[Cbill](
	[BillNum] [int] IDENTITY(1,1) NOT NULL,
	[RhistId] int NOT NULL,
	[CustId] int NOT NULL,
	[CreatedDate] datetime NOT NULL,
	[BillDate] [varchar](7) NULL,
	[BillStat] [varchar](1) NULL,
	[BillAmnt] [money] NULL,
	[DueDate] Date NULL,
	[Duedate2] Date NULL,
	[BillDtls] [varchar](120) NULL,
	[RpayNum] [varchar](20) NULL,
	[SubTot1] [money] NULL,
	[SubTot2] [money] NULL,
	[SubTot3] [money] NULL,
	[SubTot4] [money] NULL,
	[SubTot5] [money] NULL,
	[Dunning] [varchar](150) NULL,
	[Pastdue] [bit] NULL Default(0),
	[pn_value] [money] NULL,
	[pn_type] [int] NULL Default(0),
	[invoice1] [money] NULL Default(0),
	[invoice2] [money] NULL Default(0),
	[invoice3] [money] NULL Default(0),
	[invoice4] [money] NULL Default(0),
	[invoice5] [money] NULL Default(0),
	[isLateCancelled] [bit] NULL,
	 CONSTRAINT [PK_Cbill] PRIMARY KEY NONCLUSTERED 
	(
		[BillNum] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	
	,
	 CONSTRAINT [Unique_CBill] Unique 
	(
		RhistId
	),
	FOREIGN KEY ([RhistId]) REFERENCES Rhist([RhistId]),
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
	) ON [PRIMARY]