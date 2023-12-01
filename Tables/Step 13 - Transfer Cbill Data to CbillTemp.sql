--Declare Temporary Table
Create Table CbillTemp
(
	[RhistId] int NOT NULL,
	[CustId] int NOT NULL,
	[BillDate] [varchar](7) NULL,
	[BillStat] [varchar](1) NULL,
	[BillAmnt] [money] NULL,
	[DueDate] Date NULL,
	[Duedate2] Date NULL,
	[BillDtls] [varchar](120) NULL,
	[RpayNum] [varchar](20) NULL,
	[SubTot1] [money] NULL,
	[SubTot2] [money] NULL,
	[SubTot3] [money] NULL,
	[SubTot4] [money] NULL,
	[SubTot5] [money] NULL,
	[Dunning] [varchar](150) NULL,
	[Pastdue] [bit] NULL Default(0),
	[pn_value] [money] NULL,
	[pn_type] [int] NULL Default(0),
	[invoice1] [money] NULL Default(0),
	[invoice2] [money] NULL Default(0),
	[invoice3] [money] NULL Default(0),
	[invoice4] [money] NULL Default(0),
	[invoice5] [money] NULL Default(0),
	[isLateCancelled] [bit] NULL
)

--Select INsert to Temp Table
Insert CbillTemp
(
	[RhistId],[CustId],[BillDate],[BillStat],[BillAmnt],[DueDate],[Duedate2],
	[BillDtls],[RpayNum],[SubTot1],[SubTot2],[SubTot3],[SubTot4],
	[SubTot5],[Dunning],[Pastdue],[pn_value],[pn_type],[invoice1],[invoice2],
	[invoice3],[invoice4],[invoice5],[isLateCancelled]
)
Select [RhistId],b.[CustId],a.[BillDate],[BillStat],[BillAmnt],a.[DueDate],a.[Duedate2],
	[BillDtls],[RpayNum],[SubTot1],[SubTot2],[SubTot3],[SubTot4],
	[SubTot5],[Dunning],[Pastdue],[pn_value],[pn_type],[invoice1],[invoice2],
	[invoice3],[invoice4],[invoice5],[isLateCancelled]
FROM Cbill a
inner join Cust b
on a.CustNum = b.custnum
Inner Join Rhist c
on b.CustId = c.CustId
and a.BillDate = c.BillDate
where a.CustNum = b.custnum
and b.CustId = c.CustId
and a.BillDate = c.BillDate