CREATE NONCLUSTERED INDEX ix_Rhist_II
ON [dbo].[Cust_Ledger] ([CustId])
INCLUDE ([trans_date],[ledger_type],[debit],[credit])