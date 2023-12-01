--Declare Temporary Table
Create Table Rebate_MonthlyTemp
(
	[RebateId] [int] NULL,
	[CustId] int,
	[amount] [money] NULL,
	[billdate] [varchar](7) NULL,
	[submit_date] [datetime] NULL
)

--Select INsert to Temp Table
Insert Rebate_MonthlyTemp
Select a.[rebate_id],[CustId],[amount],[billdate],[submit_date]
from Rebate_Monthly a
inner join Cust c
on a.custnum = c.custnum

--Double Check Rebate_MonthlyTemps
Select * from Rebate_MonthlyTemp
