--Declare Temporary Table
Create Table custStatTemp
(
	[statCD] INT NOT NULL,
	[statDesc] [varchar](200) NULL
)

--Select INsert to Temp Table
Insert custStatTemp
Select [statCD],[statDesc]
FROM custStat
ORDER BY statCD