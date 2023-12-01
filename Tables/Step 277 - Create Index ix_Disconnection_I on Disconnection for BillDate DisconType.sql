CREATE NONCLUSTERED INDEX ix_Disconnection_I
ON [dbo].[Disconnection] ([billdate],[discontype])
INCLUDE ([custnum])