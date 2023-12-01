--Recreate Rebate_Entries Table
CREATE TABLE [Rebate_Entries]
(
	[RebateId] int identity(1,1) NOT NULL,
	
	CustId int,
	[rebate_amount] [money] NULL,
	[rebate_monthly] [money] NULL,
	[rebate_balance] [money] NULL,
	[entry_date] [datetime] NULL,
	CONSTRAINT [PK_Rebate_Entries] PRIMARY KEY CLUSTERED
	(
		[RebateId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
) ON [PRIMARY]