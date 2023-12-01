--Select Insert from Temp Table to New dd_fDisconnection Table
Insert dd_fDisconnection
(
	[CustId],[custname],RateId,[status],[remarks],[hoabalance],
	[balance],[#ofArrears],[billdate],[BookId],ZoneId,[statname],[oldarrears],
	[lcabal],[balserv],[balance1],[sewerage_bal]
)
Select 
	[CustId],[custname],RateId,[status],[remarks],[hoabalance],
	[balance],[#ofArrears],[billdate],[BookId],ZoneId,[statname],[oldarrears],
	[lcabal],[balserv],[balance1],[sewerage_bal]
from dd_fDisconnectionTemp