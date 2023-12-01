CREATE NONCLUSTERED INDEX ix_dd_fDisconnection_III
ON [dbo].[dd_fDisconnection] ([billdate],[statname],[#ofArrears],ZoneId)
INCLUDE ([CustId],[custname],RateId,[status],[remarks],[balance],[BookId],[oldarrears],[lcabal],[balserv],[balance1],[sewerage_bal])