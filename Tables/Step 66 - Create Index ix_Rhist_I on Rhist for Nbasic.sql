CREATE NONCLUSTERED INDEX ix_Rhist_I
ON [dbo].[Rhist] ([nbasic])
INCLUDE ([CustId],[Rdate])