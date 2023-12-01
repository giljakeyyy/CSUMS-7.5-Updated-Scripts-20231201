--Select Insert from Temp Table to New Zones Table
Insert Zones
(
	[ZoneNo],[ZoneName],[sewerate],[metercharge],[BookNo],[sap_area]
)
Select [ZoneNo],[ZoneName],[sewerate],[metercharge],[BookNo],[sap_area]
From ZonesTemp
order by Zoneno

--Drop Temp Table
Drop Table ZonesTemp

--Double Check New Zones
Select * from Zones