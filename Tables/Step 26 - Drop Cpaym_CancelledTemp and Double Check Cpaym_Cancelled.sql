--Select Insert from Temp Table to New Cpaym_Cancelled Table
Insert Cpaym_Cancelled
(
	[CustId],[paydate],[paytype],[ornum],[oldorno],[payamnt],
	[rcvdby],[pymntmode],[deleted_by],[remark]
)
Select [CustId],[paydate],[paytype],[ornum],[oldorno],[payamnt],
	[rcvdby],[pymntmode],[deleted_by],[remark]
From cpaym_cancelledTemp
order by paydate

--Drop TempTable
Drop Table cpaym_cancelledTemp

--Double Check New Cbill
Select * from Cpaym_Cancelled