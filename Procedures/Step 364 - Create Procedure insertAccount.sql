CREATE PROCEDURE [dbo].[insertAccount] 
	-- Add the parameters for the stored procedure here
	@CustId int,
	@info varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--INSERT forSyncAccount (custnum,dateinserted) values (@custnum, getdate());
	BEGIN
	   IF EXISTS (SELECT CustId FROM forSyncAccount 
					   WHERE 
						CustId = @CustId
						AND info = @info)
	   BEGIN
		   UPDATE 
			forSyncAccount 
		   SET dateinserted=getdate() 
		   WHERE CustId = @CustId
		   AND info = @info
	   END
	   ELSE
	   BEGIN
		   INSERT INTO forSyncAccount (CustId,dateinserted, info)
		   VALUES (@CustId, getdate(), @info)
	   END
	END
END
