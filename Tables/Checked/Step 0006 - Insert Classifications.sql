--Select Insert from Temp Table to New Rates Table
Insert claSSifications
(
	[classificationCode],[claSSification],[code],[classificationGroupID]
)
Select [RateCd],[RateName],[code],[rgroupid]
From RatesTemp
order by [RateCd];