ALTER PROCEDURE [dbo].[sp_NBASICupd]
	-- Add the parameters for the stored procedure here
	@RateId int,
	@ZoneId int,
	@cons decimal,
	@CustId int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF(@cons <= 10 and Exists(Select RateId from Rates where RateId = @RateId and RateCd ='R8'))
    BEGIN
		select distinct minbill as NBASIC from bill where RateId = @RateId
		and ZoneId = @ZoneId
    END
	ELSE
	BEGIN
		select
			CASE
				WHEN @cons <= 10 THEN
					a.minbill 
				WHEN @cons > 10 and @cons <= 20 THEN
					((@cons - 10) * a.rate1) + a.minbill
				WHEN @cons > 20 and @cons <= 30 THEN
					((@cons - 20) * a.rate2) + a.minbill + (a.rate1 * 10)
				WHEN @cons > 30 and @cons <= 50 THEN
					((@cons - 30) * a.rate3) + a.minbill + (a.rate1 * 10) + (a.rate2 * 10)
				WHEN @cons > 50 and @cons <= 70  THEN
					((@cons - 50) * a.rate4) + a.minbill + (a.rate1 * 10) + (a.rate2 * 10) + (a.rate3 * 20)
				WHEN @cons > 70  and @cons <= 100 THEN
					((@cons - 70) * a.Rate5) + a.MinBill + (a.Rate1 * 10) + (a.Rate2 * 10) + (a.Rate3 * 20) + (a.Rate4 * 20)
				WHEN @cons > 100 THEN
					((@cons - 100) * a.Rate6) + a.MinBill + (a.Rate1 * 10) + (a.Rate2 * 10) + (a.Rate3 * 20) + (a.Rate4 * 20) + (a.Rate5 * 30)
				END AS NBASIC
		from
		(
			select distinct RateId,minbill,rate1,rate2,rate3,rate4,rate5,rate6,rate7 
			from bill 
			where ZoneId=@ZoneId and RateId = @RateId
		) a
	END
END
