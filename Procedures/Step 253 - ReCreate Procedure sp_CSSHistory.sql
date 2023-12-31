ALTER PROCEDURE [dbo].[sp_CSSHistory]
    @_param nvarchar(100),
    @mode varchar(1),
    @bookno varchar(10),
    @zoneno varchar(10),
    @ratecd varchar(10),
    @mtype varchar(10),
    @billdate varchar(10),
    @senior varchar(10),
    @rgroupid varchar(10),
    @status varchar(10),
    @contract varchar(20),
    @iswriteoff int,
    @brgy varchar(200) = ''
AS
BEGIN
    SET NOCOUNT ON;

	set @_param = '"' + @_param + '"';
	IF(LEN(@_param) <> 2)
	BEGIN
		
		SELECT  DISTINCT 
		TOP 100 a.bookno,a.zoneno,a.CustId,[Customer No.],[ATM Bankref],[Account Name]
		,[Classification],[Status],[Sequence #],[Meter No.],[Last Reading],g.cons1 [Last Consumption],[Bill St. Address]
		,a.[ccelnumber] [Phone Number]
		,h.[Water Balance],h.[Sewerage],h.[Old Arrears],h.[Penalty Balance],h.[SERVICE CHARGE] AS [Meter Charge]
		,ISNULL(h.[Reconnection Fee],0) AS [Reconnection Fee]
		,ISNULL(h.[Guarantee Deposit],0) AS [Guarantee Deposit]
		,h.[Total Balance]
		,[Posted Bill Number],[Posted Payment date],
		[Last PN #],[Last PN Payment],[Last PN Payment Date]
		,[Old Customer #], [Senior Date], [TCT No.] 
		,bb.barangay
		FROM
		(
			select * from vw_Cust  where 
			(CONTAINS([Customer No.],@_param))
			OR
			(CONTAINS([Meter No.],@_param)) 
			OR
			(CONTAINS([Old Customer #],@_param))
			OR
			(CONTAINS([ATM Bankref],@_param))
			OR
			(CONTAINS([Bill St. Address],@_param))
			OR
			(CONTAINS([Account Name],@_param))
			OR
			(CONTAINS([TCT No.],@_param))
		) a 
		LEFT JOIN CBill f 
		on a.[Posted Bill Number]  = f.billnum 
		and a.CustId = f.CustId
		LEFT JOIN rhist g on g.RhistId = f.RhistId 
		and g.CustId=a.CustId
		LEFT JOIN barangays bb on a.[brgyid] = bb.[brgyid] 
		LEFT JOIN vw_ledger h
		on a.CustId = h.CustId

	END
	ELSE IF(LEN(@_param) <= 2)
	BEGIN
		
		select  distinct 
		a.bookno,a.zoneno,a.CustId,[Customer No.],[ATM Bankref],[Account Name]
		,[Classification],[Status],[Sequence #],[Meter No.],[Last Reading],g.cons1 [Last Consumption],[Bill St. Address]
		,a.[ccelnumber] [Phone Number]
		,h.[Water Balance],h.[Sewerage],h.[Old Arrears],h.[Penalty Balance],h.[SERVICE CHARGE] AS [Meter Charge]
		,ISNULL(h.[Reconnection Fee],0) AS [Reconnection Fee]
		,ISNULL(h.[Guarantee Deposit],0) AS [Guarantee Deposit]
		,h.[Total Balance]
		,[Posted Bill Number],[Posted Payment date],
		[Last PN #],[Last PN Payment],[Last PN Payment Date]
		,[Old Customer #], [Senior Date], [TCT No.] 
		,bb.barangay
		FROM vw_Cust a 
		LEFT JOIN CBill f 
		on a.[Posted Bill Number]  = f.billnum 
		and a.CustId = f.CustId
		LEFT JOIN rhist g on g.RhistId = f.RhistId 
		and g.CustId=a.CustId
		LEFT JOIN barangays bb on a.[brgyid] = bb.[brgyid] 
		LEFT JOIN vw_ledger h
		on a.CustId = h.CustId
		
		WHERE 
		--Add Billed as Filter
		(len(@billdate) <= 6 or f.BillDate = @billdate)
		
		and
		--Add Status as Filter
		(@status = 'All' or @status = '' or convert(Varchar(20),[StatVal]) = @status)
		--Add GroupId as Filter
		and
		(@rgroupid = 'All' or @rgroupid = '' or convert(Varchar(20),RGroupid) = @rgroupid)
		--Add RateCode as Filter
		and
		(@ratecd = 'All' or @ratecd = '' or RateCd = @ratecd)
		--Add MType as Filter
		and
		(@mtype = 'All' or @mtype = '' or convert(Varchar(20),mtype1) = @mtype)
		--Add BookNo as Filter
		and
		(@bookno = 'All' or @bookno = '' or BookNo = @bookno)
		--Add Zoneno as Filter
		and
		(@zoneno = 'All' or @zoneno = '' or ZoneNo = @ZoneNo)
		--Add Senior as Filter
		and
		(len(@senior) <= 0 or (len([senior date]) > 0 and [senior date] >= getdate()))
		--Add Contract as Filter
		and
		(@contract = 'All' or @contract = '' or [Contract] = @contract)
		--Add isWriteoff as Filter
		and
		(@iswriteoff <> 1 or iswriteoff = @iswriteoff)
		--Add brgy as Filter
		and
		(@brgy = 'All' or @brgy = '' or convert(Varchar(20),a.brgyid) = @brgy)
		
	END
END

