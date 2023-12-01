CREATE NONCLUSTERED INDEX ix_Rhist_VIII
ON [dbo].[Rhist] ([BookId],[BillDate],[nbasic])
INCLUDE ([RhistId],[CustId],[RateId],[Cons1],[FF3Cd],[DueDate],[arrears],[sept_fee])