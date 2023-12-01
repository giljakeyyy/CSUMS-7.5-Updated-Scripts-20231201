--Select Insert from Temp Table to New [GDForentry] Table
Insert [GDForentry]
(
	[CustId],[Water],[Penalty],[OldArrears],
	[GD],[Bill1],[Bill2],[Bill3],[Bill4],
	[Bill5],[Bill6],[Ave],[AutoComp],
	[SubmittedComp],[DateSubmitted]
)
Select [CustId],[Water],[Penalty],[OldArrears],
	[GD],[Bill1],[Bill2],[Bill3],[Bill4],
	[Bill5],[Bill6],[Ave],[AutoComp],
	[SubmittedComp],[DateSubmitted]
From GDForentryTemp
order by [DateSubmitted]

--Drop Temp Table
Drop Table GDForentryTemp

--Double Check New [GDForentry]
Select * from [GDForentry]