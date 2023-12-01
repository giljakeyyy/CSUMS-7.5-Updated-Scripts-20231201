--Create New Table
CREATE TABLE [dbo].[Zones](
	[ZoneId] int identity(1,1),
	[ZoneNo] [varchar](8) NOT NULL,
	[ZoneName] [varchar](100) NULL,
	[sewerate] [numeric](6, 2) NOT NULL,
	[metercharge] [numeric](12, 2) NULL,
	[BookNo] [varchar](8) NULL,
	[sap_area] [varchar](100) NULL,
	 CONSTRAINT [PK_Zones] PRIMARY KEY NONCLUSTERED 
	(
		[ZoneId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	
	) ON [PRIMARY]
