ALTER PROCEDURE [dbo].[Cashier_ReprintOR]
	@custnum VARCHAR(50),
	@date1 VARCHAR(10),
	@date2 VARCHAR(10),
	@paymentcenter VARCHAR(MAX),
	@pymnttype int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--Get Modes and Insert to Temp Table
	set @paymentcenter = @paymentcenter + ','
	Declare @PaymentCenterTable as Table(pymntmode varchar(3))
	declare @ctr as int
	set @ctr = 1
	declare @Delimit as varchar(3)
	set @Delimit = ''
	while(@ctr <= len(@paymentcenter))
	BEGIN
		if(SUBSTRING(@paymentcenter,@ctr,1) <> ',')
		BEGIN
			set @Delimit = @Delimit + SUBSTRING(@paymentcenter,@ctr,1)
		END
		else
		BEGIN
			Insert @PaymentCenterTable
			Values(@Delimit)

			set @Delimit = ''
		END
		set @ctr = @ctr + 1
	END

	IF(@pymnttype = 0)
	BEGIN
		Select 
		top 10
		a.Custnum [Customer No],a.Custname [Name],a.bilstadd [Bill St. Address],a.seniordate [Senior Date],oldcustnum [WD Account #],c.[statdesc] [Status],
		b.*
		FROM Cust a 
		LEFT JOIN 
		(
			SELECT a.pymntnum [Pymnt Num],CustId,a.ornum [PRIME OR],oldorno [WD OR],a.paydate [Payment Date],
			a.payamnt + ISNULL(e.PayAmnt,0.00) [Total Amount],
			a.subtot1+a.subtot3 as 'WATER',
			isnull(a.subtot2,0) as 'ARREARS',
			a.subtot4 as 'Reconnection Fee',
			a.subtot5 as 'Deposit',
			a.subtot6 as 'Penalty',
			a.subtot7 as 'Meter Charge',
			a.Subtot8 as 'OTHERS',
			a.subtot9 as 'OLD ARREARS', --DO NOT CHANGE!!! FIXED IN PROGRAM 
			a.subtot12 as 'Sewerage',
			isnull(a.rprocfee,0) as 'OLD PN' , --DO NOT CHANGE!!! FIXED IN PROGRAM 
			isnull(a.pn_amount,0) - isnull(a.rprocfee,0) as 'PN' --DO NOT CHANGE!!! FIXED IN PROGRAM 
			,ISNULL(e.Subtot1,0.00) as [Application/JO Fees]
			,ISNULL(e.Subtot2,0.00) as [Application/JO Others]
			,ISNULL(e.Subtot3,0.00) as [Guarantee Deposit]
			,case when a.pymntstat = 1 then 'NEW' else 'POSTED' end as [Payment Status]
			,a.pymntmode as [Mode],a.pymntdtl as [particular]
			FROM @PaymentCenterTable paymentcenter
			INNER JOIN cpaym a
			on paymentcenter.pymntmode = a.pymntmode
			LEFT JOIN payment_center d on a.pymntmode = d.pymntmode
			LEFT JOIN Cpaym2 e
			on a.PaymentCenter_Transaction_id = e.PaymentCenter_Transaction_id
			AND e.PaymentCenter_Transaction_id IS NOT NULL
			AND a.PayDate = e.PayDate
			AND a.ORNum = e.ORNum
			AND a.PYMNTMODE = d.PYMNTMODE
			WHERE d.cpaycenter in(' + @pymntmode + ')
		) b on a.CustId = b.CustId 
		left join custstat c on a.[status] = c.statcd where
		(a.Custnum like  '%' + @custnum + '%' or a.Custname like  '%' + @custnum + '%' or 
		[PRIME OR] like '%' + @custnum + '%' or [WD OR] like '%' + @custnum + '%') 
		and [Payment Date] between @date1 and @date2 order by [PRIME OR]
	END
	ELSE IF(@pymnttype = 1)
	BEGIN
		Select 
		top 10
		a.Custnum [Customer No],a.Cname [Name],'''' [Bill St. Address],'''' [WD Account #],
		a.*
		FROM 
		(
			SELECT a.pymntnum [Pymnt Num],a.cname,CustNum,a.ornum [PRIME OR],'''' [WD OR],convert(Date,a.paydate) [Payment Date],
			a.payamnt + ISNULL(e.PayAmnt,0.00) [Total Amount],
			a.subtot1 as 'Application/JO Fees',
			isnull(a.subtot2,0) as 'Application/JO Others',
			a.subtot3 as 'Guarantee Deposit',
			e.subtot1+e.subtot3 as 'WATER',
			isnull(e.subtot2,0) as 'ARREARS',
			e.subtot4 as 'Reconnection Fee',
			e.subtot5 as 'Deposit',
			e.subtot6 as 'Penalty',
			e.subtot7 as 'Meter Charge',
			e.Subtot8 as 'OTHERS',
			e.subtot9 as 'OLD ARREARS', --DO NOT CHANGE!!! FIXED IN PROGRAM 
			e.subtot12 as 'Sewerage',
			case when a.pymntstat = 1 then 'NEW' else 'POSTED' end as [Payment Status]
			,a.pymntmode as [Mode],a.pymntdtl as [particular]
			FROM @PaymentCenterTable paymentcenter
			INNER JOIN cpaym2 a
			on paymentcenter.pymntmode = a.pymntmode
			LEFT JOIN payment_center d on a.pymntmode = d.pymntmode
			LEFT JOIN Cpaym e
			on a.PaymentCenter_Transaction_id = e.PaymentCenter_Transaction_id
			AND e.PaymentCenter_Transaction_id IS NOT NULL
			AND a.PayDate = e.PayDate
			AND a.ORNum = e.ORNum
			AND a.PYMNTMODE = d.PYMNTMODE
			WHERE d.cpaycenter in(' + @pymntmode + ')
		) a
		WHERE a.custnum is not null
		AND (a.Custnum like  '%' + @custnum + '%' or a.cname like  '%' + @custnum + '%' or 
		[PRIME OR] like '%' + @custnum + '%') 
		and [Payment Date] between @date1 and @date2 order by [PRIME OR]
	END
END
