--Declare Temporary Table
Create Table ZonesTemp
(
	[ZoneNo] [varchar](8) NOT NULL,
	[ZoneName] [varchar](100) NULL,
	[sewerate] [numeric](6, 2) NOT NULL,
	[metercharge] [numeric](12, 2) NULL,
	[BookNo] [varchar](8) NULL,
	[sap_area] [varchar](100) NULL
);

--Select INsert to Temp Table
Insert ZonesTemp
Select [ZoneNo],[ZoneName],[sewerate],[metercharge],[BookNo],[sap_area]
FROM Zones