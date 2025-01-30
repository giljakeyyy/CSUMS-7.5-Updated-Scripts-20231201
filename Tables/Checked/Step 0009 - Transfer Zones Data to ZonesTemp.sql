--Declare Temporary Table
Create Table zonesTemp
(
	[zoneNo] [varchar](8) NOT NULL,
	[zoneName] [varchar](100) NULL,
	[seweRate] [numeric](6, 2) NOT NULL,
	[meterCharge] [numeric](12, 2) NULL,
	[BookNo] [varchar](8) NULL,
	[sap_area] [varchar](100) NULL
);

--Select INsert to Temp Table
Insert ZonesTemp
Select [ZoneNo],[ZoneName],[sewerate],[metercharge],[BookNo],[sap_area]
FROM Zones;