CREATE NONCLUSTERED INDEX ix_Cbill_VII
ON [dbo].[Cbill] ([BillDate])
INCLUDE ([CustId],[DueDate],[SubTot1])