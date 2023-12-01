CREATE NONCLUSTERED INDEX ix_cust_ledgerI
ON [dbo].[Cust_Ledger] ([ledger_type])
INCLUDE ([CustId],[trans_date],[debit],[credit])
