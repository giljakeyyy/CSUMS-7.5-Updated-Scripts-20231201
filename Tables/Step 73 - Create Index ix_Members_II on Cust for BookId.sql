CREATE NONCLUSTERED INDEX ix_Members_II
ON [dbo].[Members] ([BookId])
INCLUDE ([CustId],[SeqNo],[MeterNo1],[Pread1])