CREATE NONCLUSTERED INDEX ix_Track2_I
ON [dbo].[Track2] ([nticketno])
INCLUDE ([dtrandsd],[nstatus],[ndepartment],[cremarks])