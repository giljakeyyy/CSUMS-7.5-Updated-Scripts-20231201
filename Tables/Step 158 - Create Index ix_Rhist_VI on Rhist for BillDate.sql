CREATE NONCLUSTERED INDEX ix_Rhist_VI
ON [dbo].[Rhist] ([BillDate])
INCLUDE ([RhistId],[BookId],[RateId],[Cons1])