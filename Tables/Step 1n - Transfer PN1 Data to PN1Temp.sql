--Declare Temporary Table
Create Table PN1Temp
(
	[cpnno] [char](10) NOT NULL,
	[ddate] [datetime] NULL,
	[dtransd] [datetime] NULL,
	CustId int,
	[npn_amt] [numeric](12, 2) NOT NULL,
	[beg_bal] [numeric](12, 2) NOT NULL,
	[penalty] [numeric](12, 2) NOT NULL,
	[dduedate] [datetime] NULL,
	[end_bal] [numeric](12, 2) NOT NULL,
	[monthly_amort] [numeric](12, 2) NOT NULL,
	[number_months] [numeric](3, 0) NOT NULL,
	[username] [char](10) NOT NULL,
	[userdate] [datetime] NULL,
	[lpaid] [bit] NOT NULL,
	[last_pdate] [datetime] NULL,
	[lcompute] [bit] NOT NULL,
	[pn_remit] [numeric](12, 2) NOT NULL,
	[nrecfee] [numeric](12, 2) NOT NULL,
	[nwaterm] [numeric](12, 2) NOT NULL,
	[npenfee] [numeric](12, 2) NOT NULL,
	[nservdep] [numeric](12, 2) NOT NULL,
	[nprocfee] [numeric](12, 2) NOT NULL,
	[ninsfee] [numeric](12, 2) NOT NULL,
	[ntechfee] [numeric](12, 2) NOT NULL,
	[nwatfee] [numeric](12, 2) NOT NULL,
	[rrecfee] [numeric](12, 2) NOT NULL,
	[rwaterm] [numeric](12, 2) NOT NULL,
	[rpenfee] [numeric](12, 2) NOT NULL,
	[rservdep] [numeric](12, 2) NOT NULL,
	[rprocfee] [numeric](12, 2) NOT NULL,
	[rinsfee] [numeric](12, 2) NOT NULL,
	[rtechfee] [numeric](12, 2) NOT NULL,
	[rwatfee] [numeric](12, 2) NOT NULL,
	[nint_amt] [numeric](12, 2) NOT NULL,
	[lsubmit] [bit] NOT NULL,
	[nrate] [numeric](6, 2) NOT NULL,
	[cremarks] [varchar](50) NOT NULL,
	[cclass] [char](10) NOT NULL,
	[end_watfee] [money] NULL,
	[end_recfee] [money] NULL,
	[end_waterm] [money] NULL,
	[end_penfee] [money] NULL,
	[end_servdep] [money] NULL,
	[end_procfee] [money] NULL,
	[end_insfee] [money] NULL,
	[end_techfee] [money] NULL
);

--Select INsert to Temp Table
Insert PN1Temp
Select [cpnno],[ddate],[dtransd],b.CustId,[npn_amt],
	[beg_bal],[penalty],[dduedate],[end_bal],[monthly_amort],
	[number_months],a.[username],[userdate],[lpaid],
	[last_pdate],[lcompute],[pn_remit],[nrecfee],
	[nwaterm],[npenfee],[nservdep],[nprocfee],
	[ninsfee],[ntechfee],[nwatfee],[rrecfee],[rwaterm],
	[rpenfee],[rservdep],[rprocfee],[rinsfee],[rtechfee],
	[rwatfee],[nint_amt],[lsubmit],[nrate],[cremarks],
	[cclass],[end_watfee],[end_recfee],[end_waterm],
	[end_penfee],[end_servdep],[end_procfee] ,[end_insfee],
	[end_techfee]
FROM PN1 a
INNER JOIN Cust b
on a.CustNum = b.CustNum