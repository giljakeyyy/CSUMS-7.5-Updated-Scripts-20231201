--Select INsert to New Table
Insert TBill
(
	[BillNum],[CustId],[BillDate],[BillPeriod],[DueDate],[TotalCharges],
	[MeterNo],[RateCd],[BillType],[MeterInfo1],[MeterInfo2],
	[PrevRdg],[PresRdg],[TotalCons],[Cons1],[Amount1],[Cons2],
	[Amount2],[Cons3],[Amount3],[Cons4],[Amount4],[Cons5],
	[Amount5],[AveCons],[ConsPerMonth],[PesoPerDay],[cons6],
	[amount6],[PenaltyAfter],[AmtAfter],[VAT]
)
Select a.[BillNum],a.[CustId],a.[BillDate],b.[BillPeriod],a.[DueDate],a.SubTot1,
	c.MeterNo1,f.[RateCd],e.Zoneno,'','',
	b.Pread1,b.Read1,b.Cons1,'','','',
	'','','','','','',
	'','',convert(varchar(20),c.AveCon1) + ' cu.m./mon','','',
	'','','',null
From CBill a
inner join RHist b
on a.RhistId = b.RhistId
inner join Members c
on a.CustId = c.CustId
inner join Cust d
on a.CustId = d.CustId
inner join Zones e
on d.ZoneId = e.ZoneId
inner join rates f
on b.RateId = f.RateId
order by a.BillNum

--Double Check New Table
Select * from TBill