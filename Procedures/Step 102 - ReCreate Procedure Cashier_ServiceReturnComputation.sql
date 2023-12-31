ALTER PROCEDURE [dbo].[Cashier_ServiceReturnComputation]
	@value money,
	@variable varchar(20),
	@cons decimal,
	@CustId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @CustStat VARCHAR(5)
    DECLARE @ArrearsCount INT

    SELECT
        @CustStat = a.[Status],
        @ArrearsCount = c.[ArrearsCount]
    FROM
        [Cust] a
        OUTER APPLY
        (
            SELECT TOP 1
                [BillDate]
            FROM
                [Cbill]
            WHERE
                CustId = a.CustId
                AND [Subtot4] <= 0
            ORDER BY
                [BillDate] DESC
        ) b
        OUTER APPLY
        (
            SELECT
                COUNT(1) AS [ArrearsCount]
            FROM
                [Cbill]
            WHERE
                CustId = a.CustId
                AND [BillDate] > b.[BillDate]
        ) c
    WHERE
        a.CustId = @CustId

    SET @CustStat = ISNULL(@CustStat, '')
    SET @ArrearsCount = ISNULL(@ArrearsCount, 0)

    IF @CustStat != '1' AND @ArrearsCount >= 3
    BEGIN
        SELECT
            [value] = (@value / [vat]) * [discount],
            [destination],
            [description],
            [nid]
        FROM
            [cashier_discount]
        WHERE
            [variable] = @variable
            AND [description] LIKE '%Balik Serbisyo%';
    END
    ELSE
    BEGIN
        SELECT [value] = 0, [destination], [description], [nid] FROM [cashier_discount]
        WHERE [variable] = @variable AND [description] LIKE '%Balik Serbisyo%';
    END
END
