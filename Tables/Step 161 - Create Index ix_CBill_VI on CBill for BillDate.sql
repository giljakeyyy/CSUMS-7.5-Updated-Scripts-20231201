CREATE NONCLUSTERED INDEX ix_CBill_VI
ON [dbo].[Cbill] ([BillDate])
INCLUDE ([CustId])
