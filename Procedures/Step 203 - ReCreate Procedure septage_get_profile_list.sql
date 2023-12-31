ALTER PROCEDURE [dbo].[septage_get_profile_list]
    @ZoneID int = 0,
    @NonCustomer INT
AS
BEGIN
    SET NOCOUNT ON;

    IF LEN(ISNULL(@ZoneId, 0)) > 0 AND ISNULL(@NonCustomer, 0) = 0
    BEGIN
        SELECT
            a.[CustNum],
            a.[oldcustnum] AS [OldCustNum],
            a.[CustName],
            a.[BilStAdd] + ' ' + a.[BilCtAdd] AS [Address],
            a.[ccelnumber] AS [ContactNo],
            d.[SepCustStatDesc] AS [SeptageCustStatus],
            e.[SepLocDesc] AS [SeptageLocation],
            FORMAT(ISNULL(a.[septage_applied], ISNULL(a.[dappldate], ISNULL(CONVERT(DATETIME, b.[IDate]), c.[InstallationDate]))), 'yyyy/MM/dd (MMM dd, ddd)') AS [InstallDate],
            CONVERT(VARCHAR(10), a.[septage_duration]) + ' ' + f.[SepDurationDesc] AS [SeptageDuration],
            FORMAT(a.[septage_schedule_last], 'yyyy/MM/dd (MMM dd, ddd)') AS [SeptageScheduleLast],
            CASE ISNULL(a.[septage_info_extra], 0) WHEN 1 THEN 'Refused' ELSE '' END AS [SeptageInfoExtra]
        FROM
            [Cust] a
            LEFT JOIN [CMeters] b ON a.[CustId] = b.[CustId]
            LEFT JOIN [Application] c ON a.[ApplNum] = c.[ApplNum]
            LEFT JOIN [SeptageStatusCust] d ON a.[septage_status] = d.[SepCustStatID]
            LEFT JOIN [SeptageLocation] e ON a.[septage_location] = e.[SepLocID]
            LEFT JOIN [SeptageDurationType] f ON a.[septage_duration_type] = f.[SepDurationID]
        WHERE
            a.[ZoneId] = @ZoneId
        ORDER BY
            a.[oldcustnum]
    END
    ELSE
    BEGIN
        SELECT
            a.[CustNum],
            '' AS [OldCustNum],
            a.[CustName],
            a.[Address],
            a.[ccelnumber] AS [ContactNo],
            d.[SepCustStatDesc] AS [SeptageCustStatus],
            e.[SepLocDesc] AS [SeptageLocation],
            FORMAT(a.[septage_applied], 'yyyy/MM/dd (MMM dd, ddd)') AS [InstallDate],
            CONVERT(VARCHAR(10), a.[septage_duration]) + ' ' + f.[SepDurationDesc] AS [SeptageDuration],
            FORMAT(a.[septage_schedule_last], 'yyyy/MM/dd (MMM dd, ddd)') AS [SeptageScheduleLast],
            CASE ISNULL(a.[septage_info_extra], 0) WHEN 1 THEN 'Refused' ELSE '' END AS [SeptageInfoExtra]
        FROM
            [Septage_NonCustomer] a
            LEFT JOIN [SeptageStatusCust] d ON a.[septage_status] = d.[SepCustStatID]
            LEFT JOIN [SeptageLocation] e ON a.[septage_location] = e.[SepLocID]
            LEFT JOIN [SeptageDurationType] f ON a.[septage_duration_type] = f.[SepDurationID]
        ORDER BY
            a.[CustNum]
    END
END
