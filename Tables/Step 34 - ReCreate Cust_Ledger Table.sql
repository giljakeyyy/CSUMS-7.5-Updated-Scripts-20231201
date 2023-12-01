--Recreate cust_ledger
CREATE TABLE Cust_Ledger
(
	[TransId] bigint identity(1,1),
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
	[sap_date] [datetime] NULL,
	 CONSTRAINT [PK_Cust_Ledger] PRIMARY KEY NONCLUSTERED 
	(
		[TransId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
) ON [PRIMARY]
