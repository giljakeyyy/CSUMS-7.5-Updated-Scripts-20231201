--Create New Table
CREATE TABLE [dbo].[GDForentry]
(
	[GDForentryId] int identity(1,1),
	[CustId] int NOT NULL,
	[Water] [money] NULL,
	[Penalty] [money] NULL,
	[OldArrears] [money] NULL,
	[GD] [money] NULL,
	[Bill1] [money] NULL,
	[Bill2] [money] NULL,
	[Bill3] [money] NULL,
	[Bill4] [money] NULL,
	[Bill5] [money] NULL,
	[Bill6] [money] NULL,
	[Ave] [money] NULL,
	[AutoComp] [money] NULL,
	[SubmittedComp] [money] NULL,
	[DateSubmitted] Date NULL,
	 CONSTRAINT [PK_GDForentry] PRIMARY KEY NONCLUSTERED 
	(
		[GDForentryId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
	) ON [PRIMARY]
