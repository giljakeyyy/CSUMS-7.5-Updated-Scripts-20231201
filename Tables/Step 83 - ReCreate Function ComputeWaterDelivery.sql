ALTER FUNCTION [dbo].[compute_water_delivery]
(
    @CustNum VARCHAR(20),
    @Volume DECIMAL(9, 2),
    @Type INT,
    @Delivery INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @BasicCharge MONEY
    --DECLARE @DeliveryCharge MONEY
    DECLARE @Sign INT
    
    SELECT TOP 1
        @BasicCharge = ISNULL([BasicCharge], 0)
    FROM
        [waterdelivery_rates]
    WHERE
        --[Unit] <= @Volume AND [Type] = @Type
        [Unit] <= ABS(@Volume) AND [Type] = 0
    ORDER BY
        [Unit] DESC
    

    

    SET @BasicCharge = ISNULL(@BasicCharge, 0) * ABS(@Volume)

    
    IF @Volume >= 0
    BEGIN
        SET @Sign = 1
    END
    ELSE
    BEGIN
        SET @Sign = -1
    END
    

	RETURN @BasicCharge * @Sign
END