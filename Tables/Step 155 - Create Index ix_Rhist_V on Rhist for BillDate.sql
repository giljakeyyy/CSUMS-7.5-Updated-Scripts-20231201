CREATE NONCLUSTERED INDEX ix_Rhist_V
ON [dbo].[Rhist] ([BillDate])
INCLUDE ([RhistId],[CustId],[RateId],[Cons1])
