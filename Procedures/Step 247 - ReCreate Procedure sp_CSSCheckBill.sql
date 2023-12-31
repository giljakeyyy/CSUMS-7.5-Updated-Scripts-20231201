ALTER PROCEDURE [dbo].[sp_CSSCheckBill]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7)
AS
BEGIN

	declare @created int
	declare @unposted int
	declare @posted int
	declare @forbill int
	select @created = count(BillNum) from cbill where billdate=@billdate 
	select @unposted = count(BillNum) from cbill where billdate=@billdate and billstat='1'
	select @posted = count(BillNum) from cbill where billdate=@billdate and billstat<>'1'
	select @forbill = count(RhistId) from rhist where billdate=@billdate and nbasic>0

	select @forbill [For Billing],@unposted [Unposted], @posted [Posted],@created [Total Bill Created]

 
END
