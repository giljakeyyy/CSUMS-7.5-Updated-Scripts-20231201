CREATE NONCLUSTERED INDEX ix_Rhist_III
ON [dbo].[Rhist] ([nbasic])
INCLUDE ([CustId],[BookId],[BillDate],[Cons1],[FF3Cd],[Remark])