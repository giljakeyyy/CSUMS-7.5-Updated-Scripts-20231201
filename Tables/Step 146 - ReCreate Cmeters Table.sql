--Recreate Members Table
CREATE TABLE [CMeters](
	[CMeterId] int identity(1,1),
	[MeterNo] [varchar](20) NULL,
	[CustId] int,
	[Stat] [varchar](1) NULL,
	[Meter12] [varchar](1) NULL,
	[MType] [varchar](2) NULL,
	[MMult] [numeric](2, 0) NULL,
	[MBrand] [varchar](20) NULL,
	[IDate] [varchar](10) NULL,
	[IRead] [varchar](10) NULL,
	[RDate] [varchar](10) NULL,
	[LRead] [varchar](10) NULL,
	[ReqDate] [varchar](10) NULL,
	[username] [varchar](50) NULL,
	[dttransaction] [datetime] NULL,
	[cstat] [bit] NULL,
	[LastCons] [numeric](18, 0) NULL,
	[lprevread] [varchar](10) NULL,
	[jobnum] [varchar](10) NULL,
	[remarks] [varchar](50) NULL,
	CONSTRAINT [PK_CMeters] PRIMARY KEY CLUSTERED
	(
		[CMeterId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
) ON [PRIMARY]