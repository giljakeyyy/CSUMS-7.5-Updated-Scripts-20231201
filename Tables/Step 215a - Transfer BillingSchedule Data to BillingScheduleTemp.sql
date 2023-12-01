--Create Temp Table
CREATE TABLE BillingScheduleTemp
(
	[BookId] int,
	[BillDate] [varchar](7) NULL,
	[DueDate] [varchar](10) NULL,
	[FromDate] [varchar](10) NULL,
	[ToDate] [varchar](10) NULL,
	[DiscDate] [varchar](10) NULL,
	[Status] [varchar](1) NULL,
	[ExtractDT] [varchar](24) NULL,
	[DnldDT] [varchar](24) NULL,
	[UpldDT] [varchar](24) NULL,
	[ReaderID] [varchar](50) NULL,
	[PCA] [money] NULL
)

--Select INsert to Temp Table
Insert BillingScheduleTemp
(
	[BookId],[BillDate],[DueDate],[FromDate],
	[ToDate],[DiscDate],[Status],[ExtractDT],
	[DnldDT],[UpldDT],[ReaderID],[PCA]
)
Select 
	b.[BookId],a.[BillDate],[DueDate],[FromDate],
	[ToDate],[DiscDate],a.[Status],a.[ExtractDT],
	a.[DnldDT],a.[UpldDT],a.[ReaderID],[PCA]
From BillingSchedule a
inner join Books b
on a.BookNo = b.BookNo