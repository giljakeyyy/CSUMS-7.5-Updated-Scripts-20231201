--Select Insert from Temp Table to New PN1 Table
Insert PN1
(
	[cpnno],[ddate],[dtransd],CustId,[npn_amt],
	[beg_bal],[penalty],[dduedate],[end_bal],[monthly_amort],
	[number_months],[username],[userdate],[lpaid],
	[last_pdate],[lcompute],[pn_remit],[nrecfee],
	[nwaterm],[npenfee],[nservdep],[nprocfee],
	[ninsfee],[ntechfee],[nwatfee],[rrecfee],[rwaterm],
	[rpenfee],[rservdep],[rprocfee],[rinsfee],[rtechfee],
	[rwatfee],[nint_amt],[lsubmit],[nrate],[cremarks],
	[cclass],[end_watfee],[end_recfee],[end_waterm],
	[end_penfee],[end_servdep],[end_procfee] ,[end_insfee],
	[end_techfee]
)
Select [cpnno],[ddate],[dtransd],CustId,[npn_amt],
	[beg_bal],[penalty],[dduedate],[end_bal],[monthly_amort],
	[number_months],[username],[userdate],[lpaid],
	[last_pdate],[lcompute],[pn_remit],[nrecfee],
	[nwaterm],[npenfee],[nservdep],[nprocfee],
	[ninsfee],[ntechfee],[nwatfee],[rrecfee],[rwaterm],
	[rpenfee],[rservdep],[rprocfee],[rinsfee],[rtechfee],
	[rwatfee],[nint_amt],[lsubmit],[nrate],[cremarks],
	[cclass],[end_watfee],[end_recfee],[end_waterm],
	[end_penfee],[end_servdep],[end_procfee] ,[end_insfee],
	[end_techfee]
From PN1Temp
order by cpnno

--Drop Temp Table
Drop Table PN1Temp

--Double Check New PN1
Select * from PN1