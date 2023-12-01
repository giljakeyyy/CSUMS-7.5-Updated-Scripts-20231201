CREATE NONCLUSTERED INDEX ix_Cpaym_II
ON [dbo].[Cpaym] ([PayDate])
INCLUDE ([PymntNum],[CustId],[PymntMode],[PymntTyp],[PayAmnt],[Subtot1],[Subtot2],[Subtot3],[Subtot5],[Subtot6],[Subtot7],[Subtot8],[ORNum],[subtot9],[oldorno],[Subtot12],[rpymntnum],[Subtot13],[Subtot14],[pn_amount])