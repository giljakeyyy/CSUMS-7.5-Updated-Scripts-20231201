ALTER PROCEDURE [dbo].[sp_submitformeterrentalsubmission]
	-- Add the parameters for the stored procedure here
	@BillNum int,
	@with as varchar(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update cbill
	set subtot5 = case when @with = '1' then 0.00
	else 0.00 end,
	billamnt = subtot1 + subtot2 + subtot3 + subtot4 + 0
	where BillNum = @BillNum
	and BillStat = 1
END
