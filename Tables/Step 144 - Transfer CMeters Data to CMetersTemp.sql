--Declare Temporary Table
CREATE TABLE [CMetersTemp]
(
	[MeterNo] [varchar](20) NULL,
	[CustId] [varchar](20) NULL,
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
	[remarks] [varchar](50) NULL
)

--Select INsert to Temp Table
Insert [CMetersTemp]
Select 
	[MeterNo],b.[CustId],[Stat],[Meter12],[MType],
	[MMult],[MBrand],[IDate],[IRead],[RDate],
	[LRead],[ReqDate],a.[username],a.[dttransaction],
	a.[cstat] ,[LastCons] ,[lprevread],[jobnum],
	a.[remarks]
from CMeters a
inner join Cust b
on a.custnum = b.custnum

--Double Check [CMetersTemp]
Select * from [CMetersTemp]

