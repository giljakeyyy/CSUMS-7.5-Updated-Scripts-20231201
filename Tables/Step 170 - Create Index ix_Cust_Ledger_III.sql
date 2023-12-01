CREATE NONCLUSTERED INDEX ix_Cust_Ledger_III
ON [dbo].[Cust_Ledger] ([ledger_type],[ledger_subtype],[transaction_type],[credit],[remark],[username])
INCLUDE ([CustId],[trans_date])