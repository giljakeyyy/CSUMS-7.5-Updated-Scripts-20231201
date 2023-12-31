ALTER PROCEDURE [dbo].[sp_sapledgerbulk]
@area_id int
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @table as table
	(
		CustId int,
		[ums_date] [datetime] NULL,
		[internal_ID] [bigint] NOT NULL,
		[posting_date] [datetime] NULL,
		[trans_date] [datetime] NULL,
		[refnum] [varchar](100) NULL,
		[ledger_type] [varchar](100) NULL,
		[ledger_subtype] [varchar](100) NULL,
		[transaction_type] [int] NULL,
		[previous_reading] [int] NULL,
		[reading] [int] NULL,
		[consumption] [int] NULL,
		[debit] [money] NULL,
		[credit] [money] NULL,
		[duedate] [varchar](100) NULL,
		[remark] [varchar](150) NULL,
		[username] [varchar](100) NULL,
		TransId bigint
	)

	IF(@area_id = 0)
	BEGIN
		
		insert @table
		Select a.CustId,
		a.posting_date,
		convert(int,c.cbank_ref),
		convert(varchar(100),a.[posting_date],111),
		convert(varchar(100),a.[trans_date],111),
		[refnum],
		[ledger_type],
		[ledger_subtype],
		[transaction_type],
		[previous_reading],
		[reading],
		[consumption],
		isnull([debit],0),
		isnull([credit],0),
		convert(varchar(100),a.[duedate],111),
		[remark],
		a.[username]
		,a.TransId
		from cust_ledger a
		inner join cust c
		on a.CustId = c.CustId
		inner join zones d
		on c.ZOneId = d.ZOneId
		and isnull(d.sap_area,0) <> 0
		where isnull(a.sap_status,0) = 0
		and convert(varchar(20),posting_date,111) = '2020/01/01'
		
		Select d.sap_area as area_id,c.[custnum],
		a.posting_date as ums_date,
		a.internal_ID,
		convert(varchar(100),a.[posting_date],111) as [posting_date],
		convert(varchar(100),isnull(a.[trans_date],a.posting_date),111) as [trans_date],
		[refnum],
		[ledger_type],
		[ledger_subtype],
		[transaction_type],
		isnull([previous_reading],0) as [previous_reading],
		isnull([reading],0) as [reading],
		isnull([consumption],0) as [consumption],
		[debit],
		[credit],
		isnull(convert(varchar(100),a.[duedate],111),'') as duedate,
		[remark],
		a.[username],e.RateName as Classification,
		d.ZoneNo as ZoneNumber,g.BookNo as BookNumber
		from @table a
		inner join cust c
		on a.CustId = c.CustId
		inner join zones d
		on c.ZOneId = d.ZOneId
		inner join rates e
		on c.RateId = e.RateId
		INNER JOIN Members f
		on c.CustId = f.CustId
		INNER JOIN Books g
		on f.BookId = g.BookId

		
		update b
		set sap_status = 1,sap_date = GETDATE()
		from @table a
		inner join cust_ledger b
		on a.TransId = b.TransId
	END
	ELSE
	BEGIN
		
		
		insert @table
		Select top 1 a.CustId,
		a.posting_date,
		convert(int,c.cbank_ref),
		convert(varchar(100),a.[posting_date],111),
		convert(varchar(100),a.[trans_date],111),
		[refnum],
		[ledger_type],
		[ledger_subtype],
		[transaction_type],
		[previous_reading],
		[reading],
		[consumption],
		isnull([debit],0),
		isnull([credit],0),
		convert(varchar(100),a.[duedate],111),
		[remark],
		a.[username]
		,a.TransId
		from cust_ledger a
		inner join cust c
		on a.CustId = c.CustId
		where isnull(a.sap_status,0) = 0
		and convert(varchar(20),posting_date,111) = '2020/01/01'
		
		Select @area_id as area_id,c.[custnum],
		a.posting_date as ums_date,
		a.internal_ID,
		convert(varchar(100),a.[posting_date],111) as [posting_date],
		convert(varchar(100),isnull(a.[trans_date],a.posting_date),111) as [trans_date],
		[refnum],
		[ledger_type],
		[ledger_subtype],
		[transaction_type],
		isnull([previous_reading],0) as [previous_reading],
		isnull([reading],0) as [reading],
		isnull([consumption],0) as [consumption],
		[debit],
		[credit],
		isnull(convert(varchar(100),a.[duedate],111),'') as duedate,
		[remark],
		a.[username],d.RateName as Classification,
		e.ZoneNo as ZoneNumber,g.BookNo as BookNumber
		from @table a
		inner join cust c
		on a.CustId = c.CustId
		inner join rates d
		on c.RateId = d.RateId
		INNER JOIN Zones e
		on c.ZoneId = e.ZoneId
		INNER JOIN Members f
		on c.CustId = f.CustId
		INNER JOIN Books g
		on f.BookId = g.BookId

		
		update b
		set sap_status = 1,sap_date = GETDATE()
		from @table a
		inner join cust_ledger b
		on a.TransId = b.TransId
	END
END

