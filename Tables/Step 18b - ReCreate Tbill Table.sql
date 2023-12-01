--ReCreate TBill Table
CREATE TABLE TBill
(
	[TBillId] int identity(1,1),
	[BillNum] int NOT NULL,
	[CustId] int NOT NULL,
	[BillDate] [varchar](7) NOT NULL,
	[BillPeriod] [varchar](24) NULL DEFAULT(''),
	[DueDate] Date NULL,
	[TotalCharges] [varchar](20) NULL,
	[MeterNo] [varchar](20) NULL,
	[RateCd] [varchar](5) NULL,
	[BillType] [varchar](8) NULL,
	[MeterInfo1] [varchar](15) NULL,
	[MeterInfo2] [varchar](22) NULL,
	[PrevRdg] [varchar](10) NULL,
	[PresRdg] [varchar](10) NULL,
	[TotalCons] [varchar](10) NULL,
	[Cons1] [varchar](20) NULL,
	[Amount1] [varchar](20) NULL,
	[Cons2] [varchar](20) NULL,
	[Amount2] [varchar](20) NULL,
	[Cons3] [varchar](20) NULL,
	[Amount3] [varchar](20) NULL,
	[Cons4] [varchar](20) NULL,
	[Amount4] [varchar](20) NULL,
	[Cons5] [varchar](20) NULL,
	[Amount5] [varchar](20) NULL,
	[AveCons] [varchar](20) NULL,
	[ConsPerMonth] [varchar](30) NULL,
	[PesoPerDay] [varchar](20) NULL,
	[cons6] [varchar](20) NULL,
	[amount6] [varchar](20) NULL,
	[PenaltyAfter] [char](20) NULL,
	[AmtAfter] [char](20) NULL,
	[VAT] [money] NULL,
	 CONSTRAINT [PK_Tbill] PRIMARY KEY NONCLUSTERED 
	(
		[TBillId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([BillNum]) REFERENCES Cbill([BillNum]),
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
	) ON [PRIMARY]