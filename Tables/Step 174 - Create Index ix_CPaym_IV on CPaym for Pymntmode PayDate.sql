CREATE NONCLUSTERED INDEX ix_CPaym_IV
ON [dbo].[Cpaym] ([PymntMode],[PayDate])
INCLUDE ([PymntNum],[CustId],[PymntTyp],[PymntStat],[PayAmnt],[Subtot1],[Subtot2],[Subtot3],[Subtot5],[Subtot6],[Subtot7],[Subtot8],[PymntDtl],[ORNum],[RcvdBy],[subtot9],[oldorno],[Subtot12],[rpymntnum],[Subtot13],[Subtot14],[pn_amount],[wdorletter])
