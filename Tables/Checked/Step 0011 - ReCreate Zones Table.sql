--Create New Table
CREATE TABLE [dbo].[ZoneS]
(
	[zoneID] int identity(1,1),
	[zoneNo] [varchar](8) NOT NULL,
	[zoneName] [varchar](100) NULL,
	[seweRate] [numeric](6, 2) NOT NULL,
	[meterCharge] [numeric](12, 2) NULL,
	[BookNo] [varchar](8) NULL,
	[sap_area] [varchar](100) NULL,
	CONSTRAINT [pkZones] PRIMARY KEY NONCLUSTERED 
	(
		[zoneID] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	
)
ON [PRIMARY];
