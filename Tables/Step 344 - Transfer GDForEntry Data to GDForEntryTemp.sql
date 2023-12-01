--Declare Temporary Table
Create Table GDForentryTemp
(
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
	[DateSubmitted] [varchar](100) NULL
);

--Select INsert to Temp Table
Insert GDForentryTemp
Select b.[CustId],[Water],[Penalty],[OldArrears],
	[GD],[Bill1],[Bill2],[Bill3],[Bill4],
	[Bill5],[Bill6],[Ave],[AutoComp],
	[SubmittedComp],[DateSubmitted]
FROM [gd_forentry] a
Inner Join Cust b
on a.CustNum = b.CustNum