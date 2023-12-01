CREATE NONCLUSTERED INDEX ix_Cpaym_V
ON [dbo].[Cpaym] ([Subtot1])
INCLUDE ([CustId],[PayDate])