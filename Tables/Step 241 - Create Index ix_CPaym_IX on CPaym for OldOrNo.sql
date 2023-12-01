CREATE NONCLUSTERED INDEX ix_CPaym_IX
ON [dbo].[Cpaym] ([oldorno])
INCLUDE ([PymntNum],[CustId],[RbillNum],[PymntMode],[PymntTyp],[PymntStat],[PayAmnt],[Subtot1],[Subtot2],[Subtot3],[Subtot4],[Subtot5],[Subtot6],[Subtot7],[Subtot8],[PayDate],[PymntDtl],[ORNum],[RcvdBy],[subtot9],[Subtot10],[Subtot11],[Subtot12],[Subtot13],[Subtot14],[pn_amount],[rrecfee],[rwaterm],[rpenfee],[rservdep],[rprocfee],[rinsfee],[rtechfee],[rwatfee])

