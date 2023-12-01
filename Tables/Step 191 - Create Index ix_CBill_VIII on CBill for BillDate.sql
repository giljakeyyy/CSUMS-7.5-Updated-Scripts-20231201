CREATE NONCLUSTERED INDEX ix_CBill_VIII
ON [dbo].[Cbill] ([BillDate])
INCLUDE ([RhistId],[CustId],[BillAmnt],[SubTot1],[SubTot2],[SubTot3],[SubTot4],[SubTot5])