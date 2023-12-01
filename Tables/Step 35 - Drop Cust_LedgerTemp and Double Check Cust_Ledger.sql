--Select Insert from Temp Table to New cust_ledger Table
Insert Cust_Ledger
(
	[CustId],[posting_date],[trans_date],[refnum],[ledger_type],[ledger_subtype],
	[transaction_type],[previous_reading],[reading],[consumption],[debit],
	[credit],[duedate],[remark],[username],[sap_status],
	[sap_date]
)
Select 
	[CustId],[posting_date],[trans_date],[refnum],[ledger_type],[ledger_subtype],
	[transaction_type],[previous_reading],[reading],[consumption],[debit],
	[credit],[duedate],[remark],[username],[sap_status],
	[sap_date]
From Cust_LedgerTemp
order by [trans_date]

--Drop TempTable
Drop Table Cust_LedgerTemp

--Double Check New Cust_Ledger
Select * from Cust_Ledger