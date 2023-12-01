CREATE NONCLUSTERED INDEX ix_CPaym2_I
ON [dbo].[Cpaym2] ([PayDate])
INCLUDE ([PymntNum],[PymntTyp],[PymntStat],[PayAmnt],[Subtot1],[Subtot2],[ORNum],[RcvdBy],[PymntMode],[subtot3],[tax8])

