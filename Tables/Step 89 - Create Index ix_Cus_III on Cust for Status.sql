CREATE NONCLUSTERED INDEX ix_Cust_III
ON [dbo].[Cust] ([Status])
INCLUDE ([CustNum],[CustName],[ZoneId])