--Declare Temporary Table
CREATE TABLE CpaymTemp
(
	[OldPymntNum] [int] NOT NULL,
	[CustId] int NOT NULL,
	[RbillNum] [varchar](20) NULL,
	[PymntMode] [int] NOT NULL,
	[PymntTyp] [varchar](1) NOT NULL,
	[PymntStat] [varchar](1) NOT NULL,
	[PayAmnt] [money] NOT NULL,
	[Penalty] [money] NULL DEFAULT(0),
	[Subtot1] [money] NOT NULL DEFAULT(0),
	[Subtot2] [money] NOT NULL DEFAULT(0),
	[Subtot3] [money] NOT NULL DEFAULT(0),
	[Subtot4] [money] NOT NULL DEFAULT(0),
	[Subtot5] [money] NOT NULL DEFAULT(0),
	[Subtot6] [money] NOT NULL DEFAULT(0),
	[Subtot7] [money] NOT NULL DEFAULT(0),
	[Subtot8] [money] NOT NULL DEFAULT(0),
	[PayDate] Date NOT NULL,
	[PymntDtl] [varchar](120) NULL,
	[ORNum] [varchar](20) NULL,
	[RcvdBy] [varchar](100) NULL DEFAULT(0),
	[subtot9] [money] NOT NULL DEFAULT(0),
	[oldorno] [varchar](20) NULL,
	[ntype] [numeric](1, 0) NULL,
	[capproved] [char](10) NULL DEFAULT(''),
	[Subtot10] [money] NULL DEFAULT(0),
	[tax1] [money] NULL DEFAULT(0),
	[tax2] [money] NULL DEFAULT(0),
	[Subtot11] [money] NOT NULL DEFAULT(0),
	[Subtot12] [money] NOT NULL DEFAULT(0),
	[rpymntnum] [int] NULL,
	[Subtot13] [money] NOT NULL DEFAULT(0),
	[Subtot14] [money] NOT NULL DEFAULT(0),
	[pnno] [varchar](20) NULL DEFAULT(''),
	[pn_amount] [money] NOT NULL DEFAULT(0),
	[rrecfee] [money] NOT NULL DEFAULT(0),
	[rwaterm] [money] NOT NULL DEFAULT(0),
	[rpenfee] [money] NOT NULL DEFAULT(0),
	[rservdep] [money] NOT NULL DEFAULT(0),
	[rprocfee] [money] NOT NULL DEFAULT(0),
	[rinsfee] [money] NOT NULL DEFAULT(0),
	[rtechfee] [money] NOT NULL DEFAULT(0),
	[rwatfee] [money] NOT NULL DEFAULT(0),
	[PaymentCenter_Transaction_id] [int] NULL DEFAULT(0),
	[wdorletter] [varchar](20) NULL DEFAULT(''),
	[isLateCancelled] [bit] NULL
)


--Select INsert to Temp Table
Insert CpaymTemp
(
	[OldPymntNum],[CustId],[RbillNum],[PymntMode],[PymntTyp],[PymntStat],
	[PayAmnt],[Penalty],[Subtot1],[Subtot2],[Subtot3],[Subtot4],
	[Subtot5],[Subtot6],[Subtot7],[Subtot8],[PayDate],[PymntDtl],
	[ORNum],[RcvdBy],[subtot9],[oldorno],[ntype],[capproved],
	[Subtot10],[tax1],[tax2],[Subtot11],[Subtot12],[rpymntnum],[Subtot13],
	[Subtot14],[pnno],[pn_amount],[rrecfee],[rwaterm],[rpenfee],
	[rservdep],[rprocfee],[rinsfee],[rtechfee],[rwatfee],[PaymentCenter_Transaction_id],
	[wdorletter],[isLateCancelled]
)
Select 
	[PymntNum],b.[CustId],[RbillNum],[PymntMode],[PymntTyp],[PymntStat],
	[PayAmnt],[Penalty],[Subtot1],[Subtot2],[Subtot3],[Subtot4],
	[Subtot5],[Subtot6],[Subtot7],[Subtot8],convert(Date,[PayDate]),[PymntDtl],
	[ORNum],[RcvdBy],[subtot9],[oldorno],[ntype],[capproved],
	[Subtot10],[tax1],[tax2],[Subtot11],[Subtot12],[rpymntnum],[Subtot13],
	[Subtot14],[pnno],[pn_amount],[rrecfee],[rwaterm],[rpenfee],
	[rservdep],[rprocfee],[rinsfee],[rtechfee],[rwatfee],[PaymentCenter_Transaction_id],
	[wdorletter],[isLateCancelled]
From Cpaym a
inner join Cust b
on a.custnum = b.custnum