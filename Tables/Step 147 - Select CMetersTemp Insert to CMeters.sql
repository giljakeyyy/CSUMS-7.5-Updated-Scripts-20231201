--Select Insert from Temp Table to New CMeters Table
Insert CMeters
(
	[MeterNo],[CustId],[Stat],[Meter12],[MType],
	[MMult],[MBrand],[IDate],[IRead],[RDate],
	[LRead],[ReqDate],[username],[dttransaction],
	[cstat] ,[LastCons] ,[lprevread],[jobnum],
	[remarks]
)
Select [MeterNo],[CustId],[Stat],[Meter12],[MType],
	[MMult],[MBrand],[IDate],[IRead],[RDate],
	[LRead],[ReqDate],[username],[dttransaction],
	[cstat] ,[LastCons] ,[lprevread],[jobnum],
	[remarks]
from CMetersTemp