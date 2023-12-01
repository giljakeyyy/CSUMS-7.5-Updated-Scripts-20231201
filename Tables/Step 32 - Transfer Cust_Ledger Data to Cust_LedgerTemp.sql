--Create Temp Table
CREATE TABLE cust_ledgerTemp
(
	[CustId] int,
	[posting_date] [datetime] NULL,
	[trans_date] date NULL,
	[refnum] [varchar](100) NULL,
	[ledger_type] [varchar](100) NULL,
	[ledger_subtype] [varchar](100) NULL,
	[transaction_type] [int] NULL,
	[previous_reading] [int] NULL,
	[reading] [int] NULL,
	[consumption] [int] NULL,
	[debit] [money] NULL,
	[credit] [money] NULL,
	[duedate] Date NULL,
	[remark] [varchar](150) NULL,
	[username] [varchar](30) NULL,
	[sap_status] [int] NULL,
	[sap_date] [datetime] NULL
)

--Select INsert to Temp Table
Insert cust_ledgerTemp
(
	[CustId],[posting_date],[trans_date],[refnum],[ledger_type],[ledger_subtype],
	[transaction_type],[previous_reading],[reading],[consumption],[debit],
	[credit],[duedate],[remark],[username],[sap_status],
	[sap_date]
)
Select 
	b.[CustId],[posting_date],convert(date,[trans_date]),[refnum],[ledger_type],[ledger_subtype],
	[transaction_type],[previous_reading],[reading],[consumption],[debit],
	[credit],a.[duedate],[remark],a.[username],a.[sap_status],
	a.[sap_date]
From cust_ledger a
inner join Cust b
on a.custnum = b.custnum