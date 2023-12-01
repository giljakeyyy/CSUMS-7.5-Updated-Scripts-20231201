CREATE NONCLUSTERED INDEX ix_Bill_I
ON [dbo].[Bill] (ZoneId)
INCLUDE ([RateId])
