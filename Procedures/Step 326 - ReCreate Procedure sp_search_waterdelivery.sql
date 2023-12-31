ALTER PROCEDURE [dbo].[sp_search_waterdelivery]
	@SearchTerm VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON
    SELECT
        CustId,[Customer No.] AS [Acct #],
        [Account Name] AS [Name],
        [Bill St. Address] as [Address]
    FROM
    vw_Cust
    WHERE
    Contains([Customer No.],@SearchTerm)
	OR
    Contains([Account Name],@SearchTerm)
END
