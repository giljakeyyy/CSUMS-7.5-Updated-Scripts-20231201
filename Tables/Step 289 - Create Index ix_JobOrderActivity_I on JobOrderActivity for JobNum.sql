CREATE NONCLUSTERED INDEX ix_JobOrderActivity_I
ON [dbo].[JobOrderActivity] ([JobNum])
INCLUDE ([Jstatus])