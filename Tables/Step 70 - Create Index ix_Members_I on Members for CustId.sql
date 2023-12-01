CREATE NONCLUSTERED INDEX ix_Members_I
ON [dbo].[Members] ([CustId])
INCLUDE ([BookId],[MeterNo1],[Billnum])