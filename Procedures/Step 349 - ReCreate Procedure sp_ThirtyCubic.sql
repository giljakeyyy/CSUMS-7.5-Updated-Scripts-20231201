ALTER PROCEDURE [dbo].[sp_ThirtyCubic]
	-- Add the parameters for the stored procedure here
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
	(b.MinBill + (b.Rate1 * 10) + (b.Rate2 * 10)) as [Basic Charge] 
	FROM
	(select CustId, RateId, ZoneId from Cust where CustId = @CustId) a
	left join
	(select RateId, ZoneId, MinBill,Rate1,rate2 from Bill) b
	on a.RateId = b.RateId
	where a.RateId = b.RateId
	and a.ZoneId = b.ZoneId
END
