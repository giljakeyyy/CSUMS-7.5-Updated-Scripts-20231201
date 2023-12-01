--Recreate Cpaym_Cancelled
CREATE TABLE Cpaym_Cancelled
(
	[Id] int identity(1,1),
	[CustId] int,
	[paydate] Date NULL,
	[paytype] [varchar](100) NULL,
	[ornum] [varchar](20) NULL,
	[oldorno] [varchar](2) NULL,
	[payamnt] [money] NULL,
	[rcvdby] [varchar](100) NULL,
	[pymntmode] [int] NULL,
	[deleted_by] [varchar](100) NULL,
	[remark] [varchar](100) NULL,
	 CONSTRAINT [PK_Cpaym_Cancelled] PRIMARY KEY NONCLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([CustId]) REFERENCES Cust([CustId])
) ON [PRIMARY]