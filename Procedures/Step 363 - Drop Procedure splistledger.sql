ALTER PROCEDURE [dbo].[splistledger]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	Select top 1000 TransId from cust_ledger
	where isnull(sap_status,0) = 0
	and convert(varchar(7),posting_date,111) >= '2020/06'
END
