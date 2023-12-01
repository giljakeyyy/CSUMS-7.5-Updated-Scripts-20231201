CREATE NONCLUSTERED INDEX ix_CPaym_III
ON [dbo].[Cpaym] ([PayDate])
INCLUDE ([PymntNum],[CustId],[PymntMode],[PayAmnt],[Subtot1],[Subtot2],[Subtot3],[Subtot5],[Subtot6],[Subtot7],[Subtot8],[PymntDtl],[ORNum],[RcvdBy],[subtot9],[oldorno],[Subtot12],[rpymntnum],[Subtot13],[Subtot14],[pn_amount],[wdorletter])
