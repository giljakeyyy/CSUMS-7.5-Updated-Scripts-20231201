--Declare Temporary Table
Create Table MembersTemp
(
	[CustId] int NOT NULL,
	[BookId] int NOT NULL,
	[SeqNo] [int] NULL DEFAULT(0),
	[PRdate] VarChar(7) NULL,
	[MeterNo1] [varchar](20) NULL DEFAULT(''),
	[Mtype1] [varchar](2) NULL DEFAULT(1),
	[Mmult1] [decimal](18, 2) NULL,
	[Pread1] [varchar](10) NULL,
	[AveCon1] [decimal](18, 2) NULL,
	[MeterNo2] [varchar](20) NULL,
	[Mtype2] [varchar](1) NULL,
	[Mmult2] [decimal](18, 2) NULL,
	[Pread2] [varchar](10) NULL,
	[AveCon2] [decimal](18, 2) NULL,
	[WarnCd] [varchar](1) NULL,
	[Billnum] [varchar](20) NULL
)

--Select INsert to Temp Table
Insert MembersTemp
Select c.[CustId],b.[BookId],[SeqNo],[PRdate],[MeterNo1],
	[Mtype1],[Mmult1],[Pread1],[AveCon1],[MeterNo2],
	[Mtype2],[Mmult2],[Pread2],[AveCon2],[WarnCd],
	a.[Billnum]
from Members a
inner join Books b
on a.bookno = b.bookno
inner join Cust c
on a.custnum = c.custnum

--Double Check MembersTemps
Select * from MembersTemp
