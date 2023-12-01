--Select Insert from Temp Table to New Rebate_Entries Table
Insert Rebate_Entries
(
	CustId,[rebate_amount],[rebate_monthly],[rebate_balance]
	,[entry_date]
)
Select CustId,[rebate_amount],[rebate_monthly],[rebate_balance]
	,[entry_date]
from Rebate_EntriesTemp