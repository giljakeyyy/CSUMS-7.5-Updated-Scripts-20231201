--Declare Temporary Table
Create Table Rebate_EntriesTemp
(
	CustId int,
	[rebate_amount] [money] NULL,
	[rebate_monthly] [money] NULL,
	[rebate_balance] [money] NULL,
	[entry_date] [datetime] NULL
)

--Select INsert to Temp Table
Insert Rebate_Entries
Select b.CustId,a.[rebate_amount],a.[rebate_monthly],a.[rebate_balance]
,a.[entry_date]
from Rebate_Entries a
inner join Cust b
on a.custnum = b.custnum

--Double Check Rebate_EntriesTemp
Select * from Rebate_EntriesTemp
