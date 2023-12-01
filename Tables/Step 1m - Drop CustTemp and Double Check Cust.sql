--Select Insert from Temp Table to New Cust Table
Insert Cust
(
	[CustNum],[cbank_ref],[CustName],[BilStAdd],[BilCtAdd],[BillTel],[BillTel2],[Fax]
	,[SvcStAdd],[SvcCtAdd],[SvcTelNo],[Status],[RateId],[ZoneId],[BillNum],[DueDate],[DueDate2],
	[LastPayDate],[DiscStatus],[DiscDate] ,[PnoteNo],[PnoteAmt],[PnoteDate],
	[CStat],[Abandoned],[ApplORNum],[ORDeposit],[ORDate],
	[lpn],[legalstat] ,[legalcode],[cdeveloperid],[ccelnumber],[cemailaddr],[etext],
	[remarks],[Applnum],[BuyerClassID],[Age],[Sex] ,[Civil_Status],[Birthday],
	[zip_code],[type_application],[company_name],[authorized_rep],[designation],[Nature_bus],
	[Year_bus],[Fox_no],[Sec_reg_no],[Picturepath],[dappldate],[oldcustnum],
	[lmetercharge],[dmetercharge],[PenaltyStat],[PenaltyAmt],[SeniorDate],
	[SeniorID],[ServAppl],[UserName],[Dttransaction],
	[polypoint1],[polypoint2],[polypoint3],
	[polypoint4],[singlepoint1],[singlepoint2],[pan],[brgyid],
	[iswriteoff],[Block],[Lot],[CTC],[municipality_id],[sap_status],[sap_date],
	[septage_status],[septage_location],[septage_applied],[septage_duration],
	[septage_duration_type],[septage_schedule_last],[septage_info_extra],
	[nprint_Contract]
)
Select [CustNum],[cbank_ref],[CustName],[BilStAdd],[BilCtAdd],[BillTel],[BillTel2],[Fax]
	,[SvcStAdd],[SvcCtAdd],[SvcTelNo],[Status],[RateId],[ZoneId],[BillNum],[DueDate],[DueDate2],
	[LastPayDate],[DiscStatus],[DiscDate] ,[PnoteNo],[PnoteAmt],[PnoteDate],
	[CStat],[Abandoned],[ApplORNum],[ORDeposit],[ORDate],
	[lpn],[legalstat] ,[legalcode],[cdeveloperid],[ccelnumber],[cemailaddr],[etext],
	[remarks],[Applnum],[BuyerClassID],[Age],[Sex] ,[Civil_Status],[Birthday],
	[zip_code],[type_application],[company_name],[authorized_rep],[designation],[Nature_bus],
	[Year_bus],[Fox_no],[Sec_reg_no],[Picturepath],[dappldate],[oldcustnum],
	[lmetercharge],[dmetercharge],[PenaltyStat],[PenaltyAmt],[SeniorDate],
	[SeniorID],[ServAppl],[UserName],[Dttransaction],
	[polypoint1],[polypoint2],[polypoint3],
	[polypoint4],[singlepoint1],[singlepoint2],[pan],[brgyid],
	[iswriteoff],[Block],[Lot],[CTC],[municipality_id],[sap_status],[sap_date],
	[septage_status],[septage_location],[septage_applied],[septage_duration],
	[septage_duration_type],[septage_schedule_last],[septage_info_extra],
	[nprint_Contract]
FROM CustTemp

--Drop Temp Table
Drop Table CustTemp
--Double Check New Cust
Select * from Cust