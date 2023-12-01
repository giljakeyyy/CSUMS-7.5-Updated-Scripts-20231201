CREATE NONCLUSTERED INDEX ix_RHist_IX
ON [dbo].[Rhist] ([BookId],[BillDate],[nbasic])
INCLUDE ([RhistId],[CustId],[RateId],[Pread1],[Read1],[Cons1],[FF1Cd],[FF3Cd],[Remark])