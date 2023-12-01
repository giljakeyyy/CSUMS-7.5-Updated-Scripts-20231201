CREATE NONCLUSTERED INDEX ix_Cpaym_VI
ON [dbo].[Cpaym] ([Subtot1])
INCLUDE ([CustId],[PymntStat],[PayDate])
