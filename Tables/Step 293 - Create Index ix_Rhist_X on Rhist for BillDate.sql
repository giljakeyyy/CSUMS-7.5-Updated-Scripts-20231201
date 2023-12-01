CREATE NONCLUSTERED INDEX ix_Rhist_X
ON [dbo].[Rhist] ([BillDate])
INCLUDE ([RhistId],[CustId],[BookId],[Rdate],[Cons1],[nbasic],[DueDate],[BillPeriod])