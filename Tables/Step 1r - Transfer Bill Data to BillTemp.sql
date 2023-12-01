--Declare Temporary Table
Create Table BillTemp
(
	[RateId] int,
	[ZOneId] int,
	[MinBill] [decimal](18, 3) NULL,
	[Cons1] [decimal](18, 3) NULL,
	[Rate1] [decimal](18, 3) NULL,
	[Cons2] [decimal](18, 3) NULL,
	[Rate2] [decimal](18, 3) NULL,
	[Cons3] [decimal](18, 3) NULL,
	[Rate3] [decimal](18, 3) NULL,
	[Cons4] [decimal](18, 3) NULL,
	[Rate4] [decimal](18, 3) NULL,
	[Cons5] [decimal](18, 3) NULL,
	[Rate5] [decimal](18, 3) NULL,
	[minbill2] [money] NULL,
	[Cons6] [decimal](18, 3) NULL,
	[Rate6] [decimal](18, 3) NULL,
	[Cons7] [decimal](18, 3) NULL,
	[Rate7] [decimal](18, 3) NULL
);

--Select INsert to Temp Table
Insert BillTemp
Select b.[RateId], c.[ZOneId] ,[MinBill], [Cons1],
	[Rate1],[Cons2],[Rate2],[Cons3],[Rate3],
	[Cons4],[Rate4],[Cons5],[Rate5],[minbill2],
	[Cons6],[Rate6],[Cons7],[Rate7]
FROM Bill a
INNER JOIN Rates b
on a.RateCd = b.RateCd
INNER JOIN Zones c
on a.BillType = c.ZoneNo