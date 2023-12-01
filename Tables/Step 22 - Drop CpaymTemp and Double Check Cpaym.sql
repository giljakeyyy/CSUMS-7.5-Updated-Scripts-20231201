--Select Insert from Temp Table to New Cpaym Table
Insert Cpaym
(
	[OldPymntNum],[CustId],[RbillNum],[PymntMode],[PymntTyp],[PymntStat],
	[PayAmnt],[Penalty],[Subtot1],[Subtot2],[Subtot3],[Subtot4],
	[Subtot5],[Subtot6],[Subtot7],[Subtot8],[PayDate],[PymntDtl],
	[ORNum],[RcvdBy],[subtot9],[oldorno],[ntype],[capproved],
	[Subtot10],[tax1],[tax2],[Subtot11],[Subtot12],[rpymntnum],[Subtot13],
	[Subtot14],[pnno],[pn_amount],[rrecfee],[rwaterm],[rpenfee],
	[rservdep],[rprocfee],[rinsfee],[rtechfee],[rwatfee],[PaymentCenter_Transaction_id],
	[wdorletter],[isLateCancelled],CreatedDate
)
Select 
	[OldPymntNum],[CustId],[RbillNum],[PymntMode],[PymntTyp],[PymntStat],
	[PayAmnt],[Penalty],[Subtot1],[Subtot2],[Subtot3],[Subtot4],
	[Subtot5],[Subtot6],[Subtot7],[Subtot8],convert(Date,[PayDate]),[PymntDtl],
	[ORNum],[RcvdBy],[subtot9],[oldorno],[ntype],[capproved],
	[Subtot10],[tax1],[tax2],[Subtot11],[Subtot12],[rpymntnum],[Subtot13],
	[Subtot14],[pnno],[pn_amount],[rrecfee],[rwaterm],[rpenfee],
	[rservdep],[rprocfee],[rinsfee],[rtechfee],[rwatfee],[PaymentCenter_Transaction_id],
	[wdorletter],[isLateCancelled],convert(Date,[PayDate])
From CpaymTemp
order by [OldPymntNum]

--Drop TempTable
Drop Table CpaymTemp

--Double Check New Cbill
Select * from Cpaym