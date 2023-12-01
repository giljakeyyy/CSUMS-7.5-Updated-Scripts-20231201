--Recreate Members Table
CREATE TABLE [Members](
	[MemberId] int identity(1,1),
	[CustId] int NOT NULL,
	[BookId] int NOT NULL,
	[SeqNo] [int] NULL DEFAULT(0),
	[PRdate] [varchar](10) NULL,
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
	[Billnum] [varchar](20) NULL,
	CONSTRAINT [PK_Members] PRIMARY KEY CLUSTERED
	(
		[MemberId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId]),
	FOREIGN KEY ([BookId]) REFERENCES Books([BookId])
) ON [PRIMARY]