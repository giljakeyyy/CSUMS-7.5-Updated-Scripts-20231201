--Declare Temporary Table
Create Table RhistTemp
(
	[CustId] int NOT NULL,
	[BookId] int NOT NULL,
	[SeqNo] [int] NULL,
	[RateId] int,
	[BillDate] [varchar](7) NOT NULL,
	[Rdate] Date NULL,
	[Rtime] [varchar](15) NULL,
	[Pread1] [varchar](10) NULL,
	[Read1] [varchar](10) NULL,
	[Cons1] [decimal](18, 2) NULL,
	[Pread2] [varchar](10) NULL,
	[Read2] [varchar](10) NULL,
	[Cons2] [decimal](18, 2) NULL,
	[RangeCd] [varchar](1) NULL,
	[Tries] [varchar](1) NULL,
	[MissCd] [varchar](1) NULL,
	[WarnCd] [varchar](1) NULL,
	[FF1Cd] [varchar](2) NULL,
	[FF2Cd] [varchar](2) NULL,
	[FF3Cd] [varchar](2) NULL,
	[Remark] [varchar](50) NULL,
	[nbasic] [money] NULL,
	[DueDate] Date NULL,
	[BillPeriod] [varchar](24) NULL,
	[arrears] [numeric](18, 2) NULL,
	[OldArrears1] [numeric](18, 2) NULL,
	[sept_fee] [money] NULL DEFAULT(0),
	[nrw] [int] NULL,
	[GPSLOC] [varchar](100) NULL,
	[IsPaid] [int] NULL,
	[PaymentMode] [varchar](50) NULL,
	[PaymentDate] Date NULL,
	[GPSHLOC] [varchar](100) NULL
);

--Select INsert to Temp Table
Insert RhistTemp
Select b.[CustId],c.[BookId],[SeqNo],d.[RateId],a.[BillDate],[Rdate],
	[Rtime],[Pread1],[Read1],[Cons1],[Pread2],[Read2],[Cons2],
	[RangeCd] ,[Tries],[MissCd],[WarnCd],[FF1Cd],
	[FF2Cd],[FF3Cd],[Remark],[nbasic],a.[DueDate],[BillPeriod],
	[arrears],[OldArrears1],[sept_fee],[nrw],[GPSLOC],
	[IsPaid],[PaymentMode],[PaymentDate],[GPSHLOC]
FROM RHIST a
Inner Join Cust b
on a.CustNum = b.CustNum
Inner Join Books c
on a.BookNo = c.BookNo
INNER JOIN Rates d
on a.Rate = d.RateCd;