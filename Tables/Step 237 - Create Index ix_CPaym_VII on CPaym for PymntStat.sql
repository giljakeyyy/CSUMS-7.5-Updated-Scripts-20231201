CREATE NONCLUSTERED INDEX ix_CPaym_VII
ON [dbo].[Cpaym] ([PymntStat])
INCLUDE ([CustId])