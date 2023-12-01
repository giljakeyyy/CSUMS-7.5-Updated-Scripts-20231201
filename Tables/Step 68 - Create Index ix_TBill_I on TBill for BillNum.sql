CREATE NONCLUSTERED INDEX ix_TBill_I
ON [dbo].[TBill] ([BillNum])
INCLUDE ([BillPeriod])
