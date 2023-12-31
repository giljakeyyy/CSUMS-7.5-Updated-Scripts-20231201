ALTER PROCEDURE [dbo].[dd_ProofList]
	-- Add the parameters for the stored procedure here
	@books varchar(MAX),
	@status int,
	@wrongstatus int,
	@disconstatus int,
	@account varchar(100),
	@billdate varchar(7),
	@finding varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get BookNo and Insert to Temp Table
	set @books = @books + ','
	Declare @BooksTable as Table(BookId int)
	declare @ctr as int
	set @ctr = 1
	declare @Delimit as varchar(10)
	set @Delimit = ''
	while(@ctr <= len(@books))
	BEGIN
		if(SUBSTRING(@books,@ctr,1) <> ',')
		BEGIN
			set @Delimit = @Delimit + SUBSTRING(@books,@ctr,1)
		END
		else
		BEGIN
			Insert @BooksTable
			Values(@Delimit)

			set @Delimit = ''
		END
		set @ctr = @ctr + 1
	END


	select c.RhistId as ID,b.bookno [Book#],d.custnum [Account No],d.oldcustnum [WDCustomer#],c.cons1 [Cons],
	d.custname [Account Name],d.bilstadd [Address],f.meterno1 [Meter#],
	c.pread1 [PrevRdg],c.read1 [PresRdg],f.avecon1 [Avg Cons],k.PrevCons,
	case when isnull(c.cons1,0) > 10 and isnull(c.cons1,0) >= isnull(f.avecon1,0) * isnull(j.avg_high,1.5) then 'High' 			 
	when isnull(f.avecon1,0) > 10 and isnull(c.cons1,0) <= isnull(f.avecon1,0) - (isnull(f.avecon1,0) * isnull(j.avg_low,0.5)) then 'Low'		
	end as [Prf Status]
	,e.finddesc [Findings],h.StatDesc [Status],i.RateCd,c.Remark,c.Nbasic,c.BillPeriod
	,f.seqno,l.ZoneNo,case when c.ff3cd = 1 then 'Approved' else 'Not Approved' end as [Approval Status] 
	,c.CustId,i.RateId,l.ZoneId
	FROM 
	@BooksTable a
	Inner Join Books b
	on a.BookId = b.BookId
	INNER JOIN Rhist c
	on b.BookId = c.BookId 
    INNER join cust d 
	on c.CustId = d.CustId 
	LEFT JOIN Finding e 
	on c.ff1cd = e.findcd 
    INNER JOIN Members f 
	on d.CustId = f.CustId 
    LEFT JOIN
	(
		select CustId,max(idate) idate from CMeters group by CustId
	) g
	on c.CustId = g.CustId  
    INNER JOIN CustStat h 
	on d.status = h.statcd
	INNER JOIN Rates i 
	on d.RateId= i.RateId
	LEFT JOIN
	(
		Select rgroupid,case when rgdesc in('Government','Residential') then 1.5 else 1.25 end as avg_high,
		case when rgdesc in('Government','Residential') then 0.5 else 0.25 end as avg_low 
		FROM RateGroup
	) j 
	on i.rgroupid=j.rgroupid
	LEFT JOIN
	(
		select isnull(cons1,0) prevcons,CustId 
		FROM Rhist 
		where billdate = convert(varchar(7),DATEADD(month, -1, cast(@billdate + '/01' as datetime)),111)
	)k 
	on d.CustId=k.CustId
	INNER JOIN Zones l
	on d.ZoneId = l.ZoneId
	LEFT JOIN Cbill m
	on c.RhistId = m.RhistId
	where c.billdate = @billdate
	--Add Reading Status as Filter
	and
	(
		(@status = 1 and c.Cons1 is not null)
		OR
		(@status = 2 and c.Cons1 is null)
		OR
		(@status = 3 and c.Remark is not null)
		OR
		(@status = 4 and (d.[Status] = 2 or d.Status = 3) and (datediff(day,g.idate,getdate()) >= 8 and datediff(day,g.idate,getdate()) <=21))
		OR
		(@status = 5 and isnull(c.cons1,0) > 10 and isnull(c.cons1,0) >= isnull(f.avecon1,0) * isnull(j.avg_high,1.5))
		OR
		(@status = 6 and isnull(f.avecon1,0) > 10 and isnull(c.cons1,0) <= isnull(f.avecon1,0) - (isnull(f.avecon1,0) * isnull(j.avg_low,0.5)))
		OR
		(@status = 7 and isnull(c.nbasic,0) > 0 and c.ff2cd = 'UP')
		OR
		(NOT(@status between 1 and 7))
	)
	--Add Wrong Cons as Filter
	and
	(
		(@wrongstatus = 1 and CAST(c.Read1 as money) - CAST(c.Pread1 as money) <> c.Cons1)
		OR
		(@wrongstatus <> 1)
	)
	--Add Disconnected as Status
	and
	(
		(@disconstatus = 1 and (d.[Status] = 2 or d.[Status] = 3))
		OR
		(@disconstatus <> 1)
	)
	--Add Finding as Filter
	and
	(
		(@finding = '' or @finding = 'NONE')
		OR
		(@finding = 'ALL' and isnull(c.ff1cd,'0') <> '0')
		OR
		(@finding <> '' and @finding <> 'NONE' and @finding <> 'ALL' and isnull(c.ff1cd,'0') = '%' + left(@finding,2) + '%')
	)
	--Add Customer Name/Number as Filter
	and
	(
		(len(isnull(@account, '')) = 0)
		OR
		(len(isnull(@account, '')) <> 0 and (d.custnum LIKE '%' + @account + '%' or d.custname like '%' + @account + '%'))
	)
	--Add BIlls not Created Yet
	and
	m.BillNum is null


END
