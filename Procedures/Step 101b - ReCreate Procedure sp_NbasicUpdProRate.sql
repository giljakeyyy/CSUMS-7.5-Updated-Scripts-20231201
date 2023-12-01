ALTER PROCEDURE [dbo].[sp_NBASICupdProRate]
	-- Add the parameters for the stored procedure here
	@RateId int,
	@ZoneId int,
	@cons decimal,
	@days decimal
AS
BEGIN

	SET NOCOUNT ON;


select (@cons/10) * a.MinBill nbasic1,(@days/30) * a.MinBill nbasic2 from
(select distinct minbill,rate1,rate2,rate3,rate4,rate5 from bill
where RateId =  @rateId and ZoneId = @ZoneId) a
END



