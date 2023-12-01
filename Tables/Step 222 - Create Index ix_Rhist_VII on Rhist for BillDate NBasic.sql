CREATE NONCLUSTERED INDEX ix_Rhist_VII
ON [dbo].[Rhist] ([BillDate],[nbasic])
INCLUDE ([RhistId],[CustId],[BookId],[RateId],[Cons1],[FF3Cd],[DueDate],[arrears],[sept_fee])