--Select Insert from Temp Table to New Rhist Table
Insert Cbill
(
	[RhistId],[CustId],[CreatedDate],[BillDate],[BillStat],[BillAmnt],[DueDate],[Duedate2],
	[BillDtls],[RpayNum],[SubTot1],[SubTot2],[SubTot3],[SubTot4],
	[SubTot5],[Dunning],[Pastdue],[pn_value],[pn_type],[invoice1],[invoice2],
	[invoice3],[invoice4],[invoice5],[isLateCancelled]
)
Select [RhistId],[CustId],getdate(),[BillDate],[BillStat],[BillAmnt],[DueDate],[Duedate2],
	[BillDtls],[RpayNum],[SubTot1],[SubTot2],[SubTot3],[SubTot4],
	[SubTot5],[Dunning],[Pastdue],[pn_value],[pn_type],[invoice1],[invoice2],
	[invoice3],[invoice4],[invoice5],[isLateCancelled]
From CbillTemp
order by billdate

--Drop TempTable
Drop Table CbillTemp

--Double Check New Cbill
Select * from Cbill