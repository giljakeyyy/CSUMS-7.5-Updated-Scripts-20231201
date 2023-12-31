ALTER PROCEDURE [dbo].[jva_pnote](
@from varchar(10),
@to varchar(10),
@encoder varchar(20),
@area varchar(10),
@mode varchar(1),
@filter varchar(1) = '0'


)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	BEGIN
		select cpnno,e.zoneno,d.bookno,b.custnum,npn_amt [Principal Amount], beg_bal [Beginning Balance],end_bal [Ending Balance],
		convert(varchar,monthly_amort) [Monthly Amortization],convert(varchar,pn_remit) [Submitted Amortization] ,convert(varchar,number_months) [No. of Months],
		convert(varchar(10),userdate,111) [Date Encoded],convert(varchar(10),last_pdate,111) [Last Paydate],
		nrecfee [Reserved Variable],nwaterm [Sewerage],npenfee [Water Penalty],nservdep [Reserved Variable 2],nprocfee [Old Arrears],ninsfee [Meter Charge],
		ntechfee [Job Order],nwatfee [Water]
		from pn1 a 
		inner join Cust b 
		on a.CustId=b.CustId 
		inner join Members c 
		on b.CustId=c.CustId
		inner join Books d 
		on c.BookId=d.BookId
		INNER JOIN Zones e
		on b.ZoneId = e.ZoneId
		where convert(varchar(10),userdate,111) between @from and @to
		--Add Rcvdby as filter
		and (@encoder = 'ALL' or @encoder = a.username)
		--Zone or Book as filter
		and (@mode = '0' or (@mode = '1' and e.Zoneno = @area) or (@mode <> '0' and @mode <> '1' and d.bookno = @area))
		--Add Type as Filter
		and 
		(
			(@filter = '1' and isnull(a.nrecfee,0) > 0) 
			or (@filter = '2' and isnull(a.nwaterm,0) > 0) 
			or (@filter = '3' and isnull(a.npenfee,0) > 0) 
			or (@filter = '4' and isnull(a.nservdep,0) > 0) 
			or (@filter = '5' and isnull(a.nprocfee,0) > 0)
			or (@filter = '6' and isnull(a.ninsfee,0) > 0)
			or (@filter = '7' and isnull(a.ntechfee,0) > 0)
			or (@filter = '8' and isnull(a.nwatfee,0) > 0)
		)

		UNION ALL
		select '','','','',sum(npn_amt), sum(beg_bal) ,sum(end_bal) ,
		 '', '','', '', '',
		sum(nrecfee) ,sum(nwaterm) ,sum(npenfee),sum(nservdep) ,
		sum(nprocfee) ,sum(ninsfee) ,sum(ntechfee) ,sum(nwatfee) 
		from pn1 a 
		inner join Cust b 
		on a.CustId=b.CustId
		inner join Members c 
		on b.CustId=c.CustId
		inner join Books d 
		on c.BookId=d.BookId
		INNER JOIN Zones e
		on b.ZoneId = e.ZoneId
		where convert(varchar(10),userdate,111) between @from and @to
		--Add Rcvdby as filter
		and (@encoder = 'ALL' or @encoder = a.username)
		--Zone or Book as filter
		and (@mode = '0' or (@mode = '1' and e.Zoneno = @area) or (@mode <> '0' and @mode <> '1' and d.bookno = @area))
		--Add Type as Filter
		and 
		(
			(@filter = '1' and isnull(a.nrecfee,0) > 0) 
			or (@filter = '2' and isnull(a.nwaterm,0) > 0) 
			or (@filter = '3' and isnull(a.npenfee,0) > 0) 
			or (@filter = '4' and isnull(a.nservdep,0) > 0) 
			or (@filter = '5' and isnull(a.nprocfee,0) > 0)
			or (@filter = '6' and isnull(a.ninsfee,0) > 0)
			or (@filter = '7' and isnull(a.ntechfee,0) > 0)
			or (@filter = '8' and isnull(a.nwatfee,0) > 0)
		)

	

	END

END
