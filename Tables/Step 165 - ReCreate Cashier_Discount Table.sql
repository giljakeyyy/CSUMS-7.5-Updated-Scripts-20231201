--Recreate Cashier_Discount
CREATE TABLE Cashier_Discount
(
	[Nid] int identity(1,1),
	[OldNid] int,
	[description] [varchar](50) NOT NULL,
	[variable] [varchar](50) NULL,
	[discount] [money] NULL,
	[vat] [money] NULL,
	[groupid] [int] NULL,
	[destination] [varchar](10) NULL,
	[old_vat] [money] NULL,
	 CONSTRAINT [PK_Cashier_Discount] PRIMARY KEY NONCLUSTERED 
	(
		[Nid] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	
) ON [PRIMARY]