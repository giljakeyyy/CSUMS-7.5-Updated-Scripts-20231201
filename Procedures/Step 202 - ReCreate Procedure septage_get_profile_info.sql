ALTER PROCEDURE [dbo].[septage_get_profile_info]
    @CustNum VARCHAR(20),
    @NonCustomer INT
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@NonCustomer, 0) = 0
    BEGIN
        SELECT
            a.[CustNum] + CASE WHEN ISNULL(a.[oldcustnum], '') != '' THEN ' (' + a.[oldcustnum]  + ')' ELSE '' END AS [CustNum],
            a.[CustName],
            a.[BilStAdd] + ' ' + a.[BilCtAdd] AS [Address],
            d.[SepCustStatDesc] AS [SeptageCustStatus],
            e.[SepLocDesc] AS [SeptageLocation],
            ISNULL(a.[septage_applied], ISNULL(a.[dappldate], ISNULL(CONVERT(DATETIME, b.[IDate]), c.[InstallationDate]))) AS [InstallDate],
            a.[septage_duration] AS [SeptageDuration],
            f.[SepDurationDesc] AS [SeptageDurationDesc],
            a.[septage_schedule_last] AS [SeptageScheduleLast],
            ISNULL(a.[septage_info_extra], 0) AS [SeptageInfoExtra]
        FROM
            [Cust] a
            LEFT JOIN [CMeters] b ON a.[CustId] = b.[CustId]
            LEFT JOIN [Application] c ON a.[ApplNum] = c.[ApplNum]
            LEFT JOIN [SeptageStatusCust] d ON a.[septage_status] = d.[SepCustStatID]
            LEFT JOIN [SeptageLocation] e ON a.[septage_location] = e.[SepLocID]
            LEFT JOIN [SeptageDurationType] f ON a.[septage_duration_type] = f.[SepDurationID]
        WHERE
            a.[CustNum] = @CustNum
    END
    ELSE
    BEGIN
        SELECT
            a.[CustNum],
            a.[CustName],
            a.[Address],
            d.[SepCustStatDesc] AS [SeptageCustStatus],
            e.[SepLocDesc] AS [SeptageLocation],
            a.[septage_applied] AS [InstallDate],
            a.[septage_duration] AS [SeptageDuration],
            f.[SepDurationDesc] AS [SeptageDurationDesc],
            a.[septage_schedule_last] AS [SeptageScheduleLast],
            ISNULL(a.[septage_info_extra], 0) AS [SeptageInfoExtra]
        FROM
            [Septage_NonCustomer] a
            LEFT JOIN [SeptageStatusCust] d ON a.[septage_status] = d.[SepCustStatID]
            LEFT JOIN [SeptageLocation] e ON a.[septage_location] = e.[SepLocID]
            LEFT JOIN [SeptageDurationType] f ON a.[septage_duration_type] = f.[SepDurationID]
        WHERE
            a.[CustNum] = @CustNum
    END
END
