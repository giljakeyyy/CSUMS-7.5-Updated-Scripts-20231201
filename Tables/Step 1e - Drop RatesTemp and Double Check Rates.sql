--Select Insert from Temp Table to New Rates Table
Insert Rates
(
	[RateCd],[RateName],[code],[rgroupid]
)
Select [RateCd],[RateName],[code],[rgroupid]
From RatesTemp
order by [RateCd]

--Drop Temp Table
Drop Table RatesTemp

--Double Check New Rates
Select * from Rates