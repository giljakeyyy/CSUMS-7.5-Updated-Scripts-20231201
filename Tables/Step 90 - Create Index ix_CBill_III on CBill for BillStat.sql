CREATE NONCLUSTERED INDEX ix_CBill_III
ON [dbo].[Cbill] ([BillStat])
INCLUDE ([CustId],[BillDate],[SubTot1])