ALTER PROCEDURE [dbo].[sp_CSSCheckDiscon]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7)
AS
BEGIN

	declare @printed int
	declare @submitted int

	select @printed = count(custnum) from dd_svDisconnection where billdate=@billdate 
	select @submitted = count(a.custnum) from dd_svDisconnection a inner join cust b on a.custnum=b.custnum where billdate=@billdate and b.Status=3


	select @printed [Printed],@submitted [Submitted]

 
END