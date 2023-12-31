--Recreate dd_fDisconnection Table
CREATE TABLE [dd_fDisconnection](
	[fDisconnectionId] int identity(1,1),
	[CustId] int,
	[custname] [varchar](100) NULL,
	RateId int,
	[status] [varchar](1) NULL,
	[remarks] [varchar](100) NULL,
	[hoabalance] [money] NULL,
	[balance] [money] NULL,
	[#ofArrears] [varchar](1) NULL,
	[billdate] [varchar](7) NULL,
	[BookId] int,
	ZoneId int,
	[statname] [varchar](50) NULL,
	[oldarrears] [money] NULL,
	[lcabal] [money] NULL,
	[balserv] [money] NULL,
	[balance1] [money] NULL,
	[sewerage_bal] [money] NULL,
	CONSTRAINT [PK_dd_fDisconnection] PRIMARY KEY CLUSTERED
	(
		[fDisconnectionId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId]),
	FOREIGN KEY ([BookId]) REFERENCES Books([BookId]),
	FOREIGN KEY ([ZoneId]) REFERENCES Zones([ZoneId]),
	FOREIGN KEY (RateId) REFERENCES Rates(RateId)
) ON [PRIMARY]