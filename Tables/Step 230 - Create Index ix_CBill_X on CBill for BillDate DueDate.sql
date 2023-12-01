CREATE NONCLUSTERED INDEX ix_CBill_X
ON [dbo].[Cbill] ([BillDate],[DueDate])
INCLUDE ([BillNum],[CustId])