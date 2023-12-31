ALTER PROCEDURE [dbo].[sp_getfordiscsubmit]
	-- Add the parameters for the stored procedure here
	@billdate varchar(10),
	@BookId int,
	@CustNum varchar(20),
	@discontype varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@discontype <> 'Perm Mainline')
	BEGIN
		Select convert(bit,0) as [ ],b.CustId,a.custnum as [Acct #]
		,c.custname as Name,b.bilstadd as [Address],isnull(c.[#ofArrears],0) as [#ofArrears]
		,[Total Balance] = isnull(d.[Total Balance],0)
		,
		isnull(d.[Water Balance],0) as [Water Balance],
		isnull(d.[Penalty Balance],0) as [Penalty Balance],
		isnull(d.Sewerage,0) as [Septage Balance],
		isnull(d.[Old Arrears],0) as [Old Arrears]
		from dd_svDisconnection a
		INNER JOIN Cust b
		on a.CustNum = b.CustNum
		inner join dd_fDisconnection c
		on b.CustId = c.CustId
		and a.billdate = c.billdate
		and c.BookId = @BookId
		and c.billdate = @billdate
		left join vw_ledger d
		on b.CustId = d.CustId
		LEFT JOIN disconnection e
		on b.CustNum = e.custnum
		and e.discontype = @discontype
		and e.billdate = @billdate
		where c.BookId = @BookId
		and a.billdate = @billdate
		and c.billdate = @billdate
		and (c.status = 1 or c.status = 2)
		and e.CustNum is null
		and (@CustNum = '' or b.CustNum = @CustNum)
	END
	ELSE
	BEGIN
		Select convert(bit,0) as [ ],b.CustId,a.custnum as [Acct #]
		,c.custname as Name,b.bilstadd as [Address],isnull(c.[#ofArrears],0) as [#ofArrears]
		,[Total Balance] = isnull(d.[Total Balance],0)
		,
		isnull(d.[Water Balance],0) as [Water Balance],
		isnull(d.[Penalty Balance],0) as [Penalty Balance],
		isnull(d.Sewerage,0) as [Septage Balance],
		isnull(d.[Old Arrears],0) as [Old Arrears]
		from dd_svDisconnection a
		INNER JOIN Cust b
		on a.CustNum = b.CustNum
		inner join dd_fDisconnection c
		on b.CustId = c.CustId
		and a.billdate = c.billdate
		and c.bookid = @bookid
		and c.billdate = @billdate
		left join vw_ledger d
		on b.CustId = d.CustId
		LEFT JOIN disconnection e
		on b.CustNum = e.custnum
		and e.discontype = @discontype
		and e.billdate = @billdate
		where c.BookId = @BookId
		and a.billdate = @billdate
		and c.billdate = @billdate
		and (c.Status = 1 or a.custnum in(Select custnum from perm_disconnection where billdate = @billdate))
		and e.CustNum is null
		and (@CustNum = '' or b.CustNum = @CustNum)
	END
END
