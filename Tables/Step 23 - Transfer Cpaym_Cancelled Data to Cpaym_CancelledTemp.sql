--Create Temp Table
CREATE TABLE cpaym_cancelledTemp
(
	[CustId] int,
	[paydate] [datetime] NULL,
	[paytype] [varchar](100) NULL,
	[ornum] [varchar](20) NULL,
	[oldorno] [varchar](2) NULL,
	[payamnt] [money] NULL,
	[rcvdby] [varchar](100) NULL,
	[pymntmode] [int] NULL,
	[deleted_by] [varchar](100) NULL,
	[remark] [varchar](100) NULL
)


--Select INsert to Temp Table
Insert cpaym_cancelledTemp
(
	[CustId],[paydate],[paytype],[ornum],[oldorno],[payamnt],
	[rcvdby],[pymntmode],[deleted_by],[remark]
)
Select 
	b.[CustId],[paydate],[paytype],[ornum],[oldorno],[payamnt],
	[rcvdby],[pymntmode],[deleted_by],[remark]
From cpaym_cancelled a
inner join Cust b
on a.custnum = b.custnum

