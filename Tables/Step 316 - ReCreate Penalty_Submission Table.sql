--Create New Table
CREATE TABLE [dbo].[Penalty_Submission]
(
	[PenaltySubmissionId] int identity(1,1),
	[PenaltyLevel] [int] NULL,
	[BillNum] int,
	[BillDate] [varchar](7) NULL,
	[CustId] int,
	[amount] [money] NULL,
	 CONSTRAINT [PK_Penalty_Submission] PRIMARY KEY NONCLUSTERED 
	(
		[PenaltySubmissionId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
	,
	FOREIGN KEY ([BillNum]) REFERENCES CBill([BillNum])
	) ON [PRIMARY]
