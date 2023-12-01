--Select Insert from Temp Table to New Penalty_Submission Table
Insert Penalty_Submission
(
	[PenaltyLevel],[BillNum],[BillDate],[CustId] ,[amount]
)
Select [PenaltyLevel],[BillNum],[BillDate],[CustId] ,[amount]
From Penalty_SubmissionTemp
order by BillDate

--Drop Temp Table
Drop Table Penalty_SubmissionTemp

--Double Check New Rhist
Select * from Penalty_Submission