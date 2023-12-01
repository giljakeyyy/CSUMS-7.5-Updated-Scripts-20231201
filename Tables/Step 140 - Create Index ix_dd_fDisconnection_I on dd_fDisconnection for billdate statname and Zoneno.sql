CREATE NONCLUSTERED INDEX ix_dd_fDisconnection_I
ON [dbo].[dd_fDisconnection] ([billdate],[statname],ZoneId)
INCLUDE ([CustId],[#ofArrears],[BookId])