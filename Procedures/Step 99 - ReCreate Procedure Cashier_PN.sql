ALTER PROCEDURE [dbo].[Cashier_PN]
	-- Add the parameters for the stored procedure here
	@CustId int,
	--@paydate datetime,
	--@pn money,
	--@refno varchar(10),
	--@cpnno int,
	--@remarks varchar(150),
	--@xuser char(10)
	@pymntnum bigint
AS
BEGIN


begin

    select isnull(rprocfee,0) from cpaym where pymntnum = @pymntnum
    and CustId = @CustId
end
END

GO


