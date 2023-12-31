ALTER PROCEDURE [dbo].[sp_CSSUpdateAccount]
	-- Add the parameters for the stored procedure here
		@CustId int,
		@custnumold varchar(20),
		@custnumnew varchar(20),
		@ZoneId int,
		@RateId int,
		@username varchar(50)
AS	
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	-------- zone log, rate log, custnum log --------
	IF(Not Exists(Select CustId from Cust where CustNum = @custnumnew and CUstId <> @CustId))
	BEGIN
	

		DECLARE @ZoneNo VARCHAR(20)
		DECLARE @RateCode VARCHAR(10)
		DECLARE @RateCd VARCHAR(10)
		DECLARE @RateName VARCHAR(50)

		SET @ZoneNo = LEFT(@custnumnew, 4)
		SET @RateCode = RIGHT(LEFT(@custnumnew, 9), 4)

		SELECT TOP 1
			@RateCd = [RateCd],
			@RateName = [RateName]
		FROM
			[rates]
		WHERE
			[code] = @RateCode
		-------- zone log, rate log, custnum log --------

		Update cust set ZoneId= @ZoneId,RateId = @RateId where CustId=@CustId
		Update cust set custnum=@custnumnew where CustId=@CustId

						
		Update cledger set custnum=@custnumnew where custnum=@custnumold								
		Update CLedger_gd set custnum=@custnumnew where custnum=@custnumold				
		Update Cledger_Service set custnum=@custnumnew where custnum=@custnumold
		Update Cledger_Stat set custnum=@custnumnew where custnum=@custnumold
		Update Cledger_Septage set custnum=@custnumnew where custnum=@custnumold
		Update CLedger1 set custnum=@custnumnew where custnum=@custnumold	
		
				
		Update pn1_bill set custnum=@custnumnew where custnum=@custnumold
	
					
		update discon_monthly_table set custnum=@custnumnew where custnum=@custnumold
		Update cpaym2 set custnum=@custnumnew where custnum=@custnumold
		Update cpaym3 set custnum=@custnumnew where custnum=@custnumold
		Update Application_OtherFees set applnum=@custnumnew where applnum=@custnumold
						
		Update Cpaym_modeHist set custnum=@custnumnew where custnum=@custnumold
		Update Rhist_Logs set custnum=@custnumnew where custnum=@custnumold
		Update Cbill_Logs set custnum=@custnumnew where custnum=@custnumold	
		Update Cpaym_Logs set custnum=@custnumnew where custnum=@custnumold	
		Update Cpaym2_Logs set custnum=@custnumnew where custnum=@custnumold


		update JobOrder
		set custnum = @custnumnew where custnum=@custnumold	

		update Application_OtherFees
		set Applnum = @custnumnew where Applnum=@custnumold	
					

	
		INSERT [cust_ledger] 
		(
			CustId, [posting_date], [trans_date], [refnum], [ledger_type], [ledger_subtype], [transaction_type], [remark], [username]
		)
		VALUES
		(@CustId, GETDATE(), NULL, '', 'ZONE', 'Zone (Change)', 17, LEFT(@custnumnew, 4), @username)
		-- || Rate || --
		INSERT [cust_ledger] (CustId, [posting_date], [trans_date], [refnum], [ledger_type], [ledger_subtype], [transaction_type], [remark], [username])
		VALUES
			(@CustId, GETDATE(), NULL, '', 'RATE', 'Rate (Change)', 18, @RateCd + ': ' + @RateName, @UserName)
		-- || Account No. || --
		INSERT [cust_ledger] (CustId, [posting_date], [trans_date], [refnum], [ledger_type], [ledger_subtype], [transaction_type], [remark], [username])
		VALUES
			(@CustId, GETDATE(), NULL, '', 'ACCTNO', 'Account No. (Change)', 19, @custnumold + ' - ' + @custnumnew, @UserName)
		-------- zone log, rate log, custnum log --------
	END
END
