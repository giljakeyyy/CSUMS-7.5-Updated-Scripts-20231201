--Create New Table
CREATE TABLE [dbo].[AppCreditDebit](
	[AppDebitCreditId] int identity(1,1),
	[CustId] int NOT NULL,
	[ApplNum] [varchar](100) NULL,
	[AdjType] [int] NULL,
	[JOAmount] [money] NULL,
	[ActualAmount] [money] NULL,
	[TotalPaid] [money] NULL,
	[Amount] [money] NULL,
	[TransDate] [datetime] NULL,
	[Username] [varchar](100) NULL,
	 CONSTRAINT [PK_AppCreditDebit] PRIMARY KEY NONCLUSTERED 
	(
		[AppDebitCreditId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
	) ON [PRIMARY]
