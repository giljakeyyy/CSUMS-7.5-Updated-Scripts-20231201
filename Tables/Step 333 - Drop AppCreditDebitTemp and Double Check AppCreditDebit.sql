--Select Insert from Temp Table to New [AppCreditDebit] Table
Insert [AppCreditDebit]
(
	[CustId],[ApplNum],[AdjType],
	[JOAmount],[ActualAmount],[TotalPaid],
	[Amount],[TransDate],[Username]
)
Select [CustId],[ApplNum],[AdjType],
	[JOAmount],[ActualAmount],[TotalPaid],
	[Amount],[TransDate],[Username]
From AppCreditDebitTemp
order by [TransDate]

--Drop Temp Table
Drop Table AppCreditDebitTemp

--Double Check New [AppCreditDebit]
Select * from [AppCreditDebit]