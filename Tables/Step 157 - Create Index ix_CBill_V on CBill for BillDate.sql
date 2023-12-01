CREATE NONCLUSTERED INDEX ix_CBill_V
ON [dbo].[Cbill] ([BillDate])
INCLUDE ([RhistId])