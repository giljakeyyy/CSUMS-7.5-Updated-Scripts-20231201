CREATE NONCLUSTERED INDEX ix_Rhist_IV
ON [dbo].[Rhist] ([BillDate],[Cons1])
INCLUDE ([CustId],[BookId],[RateId],[Pread1],[Read1],[FF1Cd],[FF3Cd],[Remark],[nbasic],[BillPeriod])