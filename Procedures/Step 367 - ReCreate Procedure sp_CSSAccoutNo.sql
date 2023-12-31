ALTER PROCEDURE [dbo].[sp_CSSAccoutNo]
	-- Add the parameters for the stored procedure here
		@RateId int,
		@ZoneId int,
		@Block varchar(20) = '',
		@Lot varchar(20) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @RCode varchar(4)
	Declare @ZoneCode varchar(4)
	Declare @Max varchar(4)
	
	set @RCode =  (Select isnull(code,'0000') from Rates where RateId=@RateId)	
	set @ZoneCode =  (Select isnull(ZoneNo,'0000') from Zones where ZoneId=@ZoneId)	

	set @Max = (Select  right('0000'+ Convert(varchar,max(right(replace(custnum,'-',''),4))+1),4) as maxtot from cust where left(custnum,9)=@ZoneCode+'-'+@RCode)
	Select @ZoneCode+ '-' + isnull(@RCode,'0000')+'-'+isnull(@Max,'0001') as NewCust
	   
END
