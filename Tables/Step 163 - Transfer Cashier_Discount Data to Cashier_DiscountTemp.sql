--Create Temp Table
CREATE TABLE Cashier_DiscountTemp
(
	[OldNid] int,
	[description] [varchar](50) NOT NULL,
	[variable] [varchar](50) NULL,
	[discount] [money] NULL,
	[vat] [money] NULL,
	[groupid] [int] NULL,
	[destination] [varchar](10) NULL,
	[old_vat] [money] NULL
)

--Select INsert to Temp Table
Insert Cashier_DiscountTemp
(
	[OldNid],[description],[variable],[discount],[vat],
	[groupid],[destination],[old_vat]
)
Select 
	[Nid],[description],[variable],[discount],[vat],
	[groupid],[destination],[old_vat]
From Cashier_Discount