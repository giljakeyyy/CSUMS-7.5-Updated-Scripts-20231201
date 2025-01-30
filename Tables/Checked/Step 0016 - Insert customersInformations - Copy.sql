--Select Insert from Temp Table to New Cust Table
Insert customersInformations
(
	[custNum],[atmRef],[customerName],[billingStreetAdd],[billingCityAdd],
	[billingTelNo1],[billingTelNo2],[FAXaddress],[svcStreetAdd],[svcCityAdd],
	[svcTelNo],[customerStatusID],[classID],[zoneID],[lastPayDate],
	[abanDoned],[developerID],[mobileNumber],[emailAddr],[applNum],
	[buyerClassID],[Sex] ,[civilStatus],[birthDay],[picturePath],
	[oldCustNum],[penaltyStat],[seniorDate],[seniorID],[userName],
	[entryDate],[polypoint1],[polypoint2],[polypoint3],[polypoint4],
	[singlepoint1],[singlepoint2],[PAN],[brgyID],[isWriteOff],[Block],
	[Lot],[CTC],[municipalityID],[sapStatus],[sapDate],
	[septage_status],[septage_location],[septage_applied],[septage_duration],
	[septage_duration_type],[septage_schedule_last],[septage_info_extra],
	[nprint_Contract],HOAcustomerID
)
Select
	[CustNum],[cbank_ref],[CustName],[BilStAdd],[BilCtAdd],
	[BillTel],[BillTel2],[Fax],[SvcStAdd],[SvcCtAdd],
	[SvcTelNo],[Status],[RateId],[ZoneId],[LastPayDate],
	[Abandoned],[cdeveloperid],[ccelnumber],[cemailaddr],[Applnum],
	[BuyerClassID],[Sex] ,[Civil_Status],[Birthday],[Picturepath],
	[oldcustnum],[PenaltyStat],[SeniorDate],[SeniorID],[UserName],
	[Dttransaction],[polypoint1],[polypoint2],[polypoint3],[polypoint4],
	[singlepoint1],[singlepoint2],[pan],[brgyid],[iswriteoff],[Block],
	[Lot],[CTC],[municipality_id],[sap_status],[sap_date],
	[septage_status],[septage_location],[septage_applied],[septage_duration],
	[septage_duration_type],[septage_schedule_last],[septage_info_extra],[nprint_Contract]
FROM CustTemp;