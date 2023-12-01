--Declare Temporary Table
Create Table Penalty_SubmissionTemp
(
	[PenaltyLevel] [int] NULL,
	[BillNum] int,
	[BillDate] [varchar](7) NULL,
	[CustId] int,
	[amount] [money] NULL
)

--Select INsert to Temp Table
Insert Penalty_SubmissionTemp
Select a.[penalty_level],a.[BillNum],[BillDate],[CustId] ,[amount]
FROM Penalty_Submission a
Inner Join Cust b
on a.CustNum = b.CustNum