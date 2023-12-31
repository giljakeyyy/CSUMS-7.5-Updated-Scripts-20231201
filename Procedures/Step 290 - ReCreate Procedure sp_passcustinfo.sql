ALTER PROCEDURE [dbo].[sp_passcustinfo]
	-- Add the parameters for the stored procedure here
	@CustId int,
	@billercode int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select rtrim(ltrim(cbank_ref)) as Atmref,CustomerName = a.custname,AccountNumber  = a.custnum,
	OldAccountNumber = a.oldcustnum,Street = a.bilstadd,
	City = a.bilctadd,BillerCode = @billercode,
	AccountStatus = a.status,MeterNumber = b.meterno1
	,Email = isnull(a.cemailaddr,'')
	,MobileNumber = isnull(a.ccelnumber,'')
	,c.RateCd as RateCode,d.Zoneno as ZoneNumber
	from cust a
	inner join members b
	on a.CustId =b.CustId
	INNER JOIN Rates c
	on a.RateId = c.RateId
	INNER JOIN Zones d
	on a.ZOneId = d.ZoneId
	where a.CustId = @CustId

END
