--Create New Table
CREATE TABLE [dbo].[Bill]
(
	[BillId] int identity(1,1),
	[RateId] int,
	[ZOneId] int,
	[MinBill] [decimal](18, 3) NULL,
	[Cons1] [decimal](18, 3) NULL,
	[Rate1] [decimal](18, 3) NULL,
	[Cons2] [decimal](18, 3) NULL,
	[Rate2] [decimal](18, 3) NULL,
	[Cons3] [decimal](18, 3) NULL,
	[Rate3] [decimal](18, 3) NULL,
	[Cons4] [decimal](18, 3) NULL,
	[Rate4] [decimal](18, 3) NULL,
	[Cons5] [decimal](18, 3) NULL,
	[Rate5] [decimal](18, 3) NULL,
	[minbill2] [money] NULL,
	[Cons6] [decimal](18, 3) NULL,
	[Rate6] [decimal](18, 3) NULL,
	[Cons7] [decimal](18, 3) NULL,
	[Rate7] [decimal](18, 3) NULL,
	 CONSTRAINT [PK_Bill] PRIMARY KEY NONCLUSTERED 
	(
		[BillId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([RateId]) REFERENCES Rates([RateId]),
	FOREIGN KEY ([ZoneId]) REFERENCES Zones([ZoneId])
	) ON [PRIMARY]
