--Select Insert from Temp Table to New rebate_monthly Table
Insert rebate_monthly
(
	[RebateId],[CustId],[amount],[billdate],[submit_date]
)
Select [RebateId],[CustId],[amount],[billdate],[submit_date]
from rebate_monthlyTemp