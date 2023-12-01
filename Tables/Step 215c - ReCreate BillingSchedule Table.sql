--Recreate BillingSchedule Table
CREATE TABLE BillingSchedule
(
	[BillingScheduleId] int identity(1,1),
	[BookId] int,
	[BillDate] [varchar](7) NULL,
	[DueDate] Date NULL,
	[FromDate] Date NULL,
	[ToDate] Date NULL,
	[DiscDate] Date NULL,
	[Status] [varchar](1) NULL,
	[ExtractDT] Date NULL,
	[DnldDT] Date NULL,
	[UpldDT] Date NULL,
	[ReaderID] [varchar](50) NULL,
	[PCA] [money] NULL,
	CONSTRAINT [PK_BillingSchedule] PRIMARY KEY CLUSTERED
	(
		[BillingScheduleId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([BookId]) REFERENCES Books([BookId])
) ON [PRIMARY]