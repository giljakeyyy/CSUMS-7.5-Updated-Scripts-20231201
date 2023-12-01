--Declare Temporary Table
Declare @Books as Table
(
	[BookNo] [varchar](8) NOT NULL,
	[GroupNo] [int] NULL,
	[Area] [varchar](100) NULL,
	[Status] [varchar](1) NULL,
	[ReaderID] [varchar](12) NULL,
	[RoverNo] [varchar](10) NULL,
	[BillDate] [varchar](7) NULL,
	[ExtractDT] [varchar](24) NULL,
	[DnldDT] [varchar](24) NULL,
	[UpldDT] [varchar](24) NULL,
	[PostDT] [varchar](24) NULL,
	[BcompDT] [varchar](24) NULL,
	[BprntDT] [varchar](24) NULL,
	[BdelvDT] [varchar](24) NULL,
	[sharing] [money] NULL,
	[sharedmonth] [varchar](7) NULL
)

--Select INsert to Temp Table
Insert @Books
Select [BookNo],[GroupNo],[Area],[Status],[ReaderID],[RoverNo],
	[BillDate],[ExtractDT],[DnldDT],[UpldDT],[PostDT],[BcompDT],
	[BprntDT],[BdelvDT],[sharing],[sharedmonth]
FROM Books

--Drop Table Books
Drop Table Books

--ReCreate Books Table
CREATE TABLE [dbo].[Books](
	[BookId] int identity(1,1),
	[BookNo] [varchar](8) NOT NULL,
	[GroupNo] [int] NULL,
	[Area] [varchar](100) NULL,
	[Status] [varchar](1) NULL,
	[ReaderID] [varchar](12) NULL,
	[RoverNo] [varchar](10) NULL,
	[BillDate] [varchar](7) NULL,
	[ExtractDT] [varchar](24) NULL,
	[DnldDT] [varchar](24) NULL,
	[UpldDT] [varchar](24) NULL,
	[PostDT] [varchar](24) NULL,
	[BcompDT] [varchar](24) NULL,
	[BprntDT] [varchar](24) NULL,
	[BdelvDT] [varchar](24) NULL,
	[sharing] [money] NULL,
	[sharedmonth] [varchar](7) NULL,
	CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED 
	(
		[BookId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]


--Select Insert from Temp Table to New Cust Table
Insert Books
(
	[BookNo],[GroupNo],[Area],[Status],[ReaderID],[RoverNo],
	[BillDate],[ExtractDT],[DnldDT],[UpldDT],[PostDT],[BcompDT],
	[BprntDT],[BdelvDT],[sharing],[sharedmonth]
)
Select [BookNo],[GroupNo],[Area],[Status],[ReaderID],[RoverNo],
	[BillDate],[ExtractDT],[DnldDT],[UpldDT],[PostDT],[BcompDT],
	[BprntDT],[BdelvDT],[sharing],[sharedmonth]
FROM @Books

--Double Check New Books
Select * from Books