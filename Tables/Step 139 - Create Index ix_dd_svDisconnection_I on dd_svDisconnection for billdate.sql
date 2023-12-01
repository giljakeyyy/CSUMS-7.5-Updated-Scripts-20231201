CREATE NONCLUSTERED INDEX ix_dd_svDisconnection_I
ON [dbo].[dd_svDisconnection] ([billdate])
INCLUDE ([custnum])