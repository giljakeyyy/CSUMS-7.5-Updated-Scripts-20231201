--Recreate Cpaym_Cancelled
CREATE TABLE Cpaym_Discount
(
	[DiscId] int identity(1,1),
	[Pymntnum] int NOT NULL,
	[OldPymntnum] int,
	[nid] [int] NOT NULL,
	[value] [money] NULL,
	[rpymntnum] [bigint] NULL,
	[ornum] [varchar](20) NULL,
	 CONSTRAINT [PK_Cpaym_Discount] PRIMARY KEY NONCLUSTERED 
	(
		[DiscId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([Pymntnum]) REFERENCES Cpaym([Pymntnum])
) ON [PRIMARY]
