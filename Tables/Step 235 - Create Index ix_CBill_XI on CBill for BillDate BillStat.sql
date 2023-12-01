CREATE NONCLUSTERED INDEX ix_CBill_XI
ON [dbo].[Cbill] ([BillDate],[BillStat])
INCLUDE ([BillNum],[RhistId],[CustId],[BillAmnt],[DueDate],[Duedate2],[BillDtls],[SubTot1],[SubTot2],[SubTot3],[SubTot4],[SubTot5])
