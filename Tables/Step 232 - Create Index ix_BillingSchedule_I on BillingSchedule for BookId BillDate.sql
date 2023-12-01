CREATE NONCLUSTERED INDEX ix_BillingSchedule_I
ON [dbo].[BillingSchedule] ([BookId],[BillDate])
INCLUDE ([ReaderID])