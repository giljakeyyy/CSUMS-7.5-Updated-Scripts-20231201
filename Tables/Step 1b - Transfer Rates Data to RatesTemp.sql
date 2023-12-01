--Declare Temporary Table
Create Table RatesTemp
(
	[RateCd] [varchar](5) NOT NULL,
	[RateName] [varchar](50) NULL,
	[code] [varchar](5) NULL,
	[rgroupid] [int] NULL
);

--Select INsert to Temp Table
Insert RatesTemp
Select [RateCd],[RateName],[code],[rgroupid]
FROM Rates