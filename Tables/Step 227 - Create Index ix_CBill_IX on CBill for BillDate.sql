CREATE NONCLUSTERED INDEX ix_CBill_IX
ON [dbo].[Cbill] ([BillDate])
INCLUDE ([CustId],[BillStat],[DueDate])