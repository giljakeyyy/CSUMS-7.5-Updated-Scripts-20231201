ALTER PROCEDURE [dbo].[sp_rebateentry]
	-- Add the parameters for the stored procedure here
	@CustId int
	,@water money
	,@monthly money
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if(@CustId not in(Select CustId from rebate_entries where rebate_balance > 0))
	begin
		set @water = @water * -1

		insert Rebate_Entries
		(
			CustId, rebate_amount, rebate_monthly, rebate_balance, entry_date
		)
		values
		(
			@CustId, @water, @monthly, @water, getdate()
		)

	end
END
