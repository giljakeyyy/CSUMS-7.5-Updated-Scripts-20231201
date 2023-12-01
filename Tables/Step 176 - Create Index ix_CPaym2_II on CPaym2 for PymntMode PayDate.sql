CREATE NONCLUSTERED INDEX ix_CPaym2_II
ON [dbo].[Cpaym2] ([PymntMode],[PayDate])
INCLUDE ([PymntNum],[custnum],[cname],[PymntTyp],[PymntStat],[PayAmnt],[Subtot1],[Subtot2],[PymntDtl],[ORNum],[RcvdBy],[subtot3],[tax8])

