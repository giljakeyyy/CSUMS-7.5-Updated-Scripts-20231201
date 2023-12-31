ALTER PROCEDURE [dbo].[sp_submit_nrw]
	@CustId int,
	@billdate varchar(100),
	@nrw int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF(NOT EXISTS(Select CustId from cbill where CustId = @CustId and billdate = @billdate))
	begin
		update rhist
		set nrw = @nrw
		where CustId = @CustId
		and billdate = @billdate
	end
END
