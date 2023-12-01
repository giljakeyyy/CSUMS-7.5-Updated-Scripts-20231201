CREATE NONCLUSTERED INDEX ix_CBill_II
ON [dbo].[Cbill] ([BillStat])
INCLUDE ([CustId],[BillDate])
