--Create Temp Table
CREATE TABLE Cpaym_DiscountTemp
(
	[Pymntnum] int NOT NULL,
	[OldPymntnum] int,
	[nid] [int] NOT NULL,
	[value] [money] NULL,
	[rpymntnum] [bigint] NULL,
	[ornum] [varchar](20) NULL
)

--Select INsert to Temp Table
Insert Cpaym_DiscountTemp
(
	[Pymntnum],[OldPymntnum],[nid],[value],[rpymntnum],
	[ornum]
)
Select 
	b.[Pymntnum],a.[Pymntnum],a.[nid],a.[value],a.[rpymntnum],
	a.[ornum]
From Cpaym_Discount a
inner join Cpaym b
on a.[Pymntnum] = b.[OldPymntNum]