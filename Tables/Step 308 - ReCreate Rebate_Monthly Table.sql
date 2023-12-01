--Recreate Rebate_Monthly Table
CREATE TABLE [Rebate_Monthly]
(
	[RebateMonthlyId] int identity(1,1),
	[RebateId] [int] NULL,
	[CustId] int,
	[amount] [money] NULL,
	[billdate] [varchar](7) NULL,
	[submit_date] Date NULL,
	CONSTRAINT [PK_Rebate_Monthly] PRIMARY KEY CLUSTERED
	(
		[RebateMonthlyId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
) ON [PRIMARY]