CREATE NONCLUSTERED INDEX ix_dd_fDisconnection_II
ON [dbo].[dd_fDisconnection] ([billdate],[BookId],[statname],ZoneId)
INCLUDE ([CustId],[#ofArrears])