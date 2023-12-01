--Declare Temporary Table
CREATE TABLE dd_fDisconnectionTemp(
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
	[ZoneId] int,
	[statname] [varchar](50) NULL,
	[oldarrears] [money] NULL,
	[lcabal] [money] NULL,
	[balserv] [money] NULL,
	[balance1] [money] NULL,
	[sewerage_bal] [money] NULL
)

--Select INsert to Temp Table
Insert dd_fDisconnectionTemp
(
	[CustId],[custname],RateId,[status],[remarks],[hoabalance],
	[balance],[#ofArrears],[billdate],[BookId],ZoneId,[statname],[oldarrears],
	[lcabal],[balserv],[balance1],[sewerage_bal]
)
Select [CustId],a.[custname],c.RateId,a.[status],a.[remarks],a.[hoabalance],
	a.[balance],a.[#ofArrears],a.[billdate],b.[BookId],c.ZoneId,a.[statname],a.[oldarrears],
	a.[lcabal],a.[balserv],a.[balance1],a.[sewerage_bal]
from dd_fDisconnection a
inner join Books b
on a.bookno = b.bookno
inner join Cust c
on a.custnum = c.custnum

--Double Check dd_fDisconnectionTemp
Select * from dd_fDisconnectionTemp

