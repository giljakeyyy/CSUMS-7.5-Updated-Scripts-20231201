ALTER PROCEDURE [dbo].[jva_billgen](@billdate1 varchar(7),@mode1 varchar(1))
	

	
AS
BEGIN

declare @billdate varchar(7)
set @billdate = @billdate1
declare	@mode varchar(1)
set @mode = @mode1
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
if (@mode = '1')
begin
	


	select c.zoneno,c.zonename,

	isnull(sum(Residential),0) as [Residential Billed Volume],
	isnull(sum(d.rstatus),0) [Res. Active],
	isnull(sum(rcount),0) as [Res. Billed Count],

	isnull(sum(Government),0) as [Government Billed Volume],  
	isnull(sum(d.gstatus),0) [Gov. Active],
	isnull(sum(gcount),0) as  [Gov. Billed Count],

	isnull(sum(Industrial),0) as [Industrial Billed Volume],
	isnull(sum(d.istatus),0) [Ind. Active],
	isnull(sum(icount),0) as  [Ind. Billed Count],

	isnull(sum(Commercial),0) as [Commercial Billed Volume],
	isnull(sum(d.cstatus),0) [Comm. Active],
	isnull(sum(ccount),0) as [Comm. Billed Count],

	isnull(sum(WholesaleBulk),0) as [WholesaleBulk Billed Volume],
	isnull(sum(d.bstatus),0) [Bulk Active],
	isnull(sum(wcount),0) as [Bulk Billed Count],

	isnull(sum(Others),0) as [Others Billed Volume],
	isnull(sum(d.ostatus),0) [Others Active],
	isnull(sum(ocount),0) as [Others Billed Count],

	isnull(sum(Residential),0) + isnull(sum(Government),0) + isnull(sum(Industrial),0) + isnull(sum(Commercial),0) + isnull(sum(WholesaleBulk),0) + isnull(sum(Others),0) [Billed Consumption GrandTotal],
	isnull(sum(rcount),0) +isnull(sum(gcount),0)+isnull(sum(icount),0)+isnull(sum(ccount),0) + isnull(sum(wcount),0) + isnull(sum(ocount),0) TotalCount


    from
	(
		select Zones.zoneno,
		case when rgroupid = 1 then [total consumption] end as 'Residential',
		case when rgroupid = 1 then total end as 'rcount',
		case when rgroupid = 2 then [total consumption] end as 'Government',  
		case when rgroupid = 2 then total end as 'gcount',  
		case when rgroupid = 3 then [total consumption] end as 'Industrial', 
		case when rgroupid = 3 then total end as 'icount', 
		case when rgroupid = 4 then [total consumption] end as 'Commercial',
		case when rgroupid = 4 then total end as 'ccount',
		case when rgroupid = 5 then [total consumption] end as 'WholesaleBulk', 
		case when rgroupid = 5 then total end as 'wcount', 
		case when rgroupid = 6 then [total consumption] end as 'Others', 
		case when rgroupid = 6 then total end as 'ocount', 

		Total from 
		Zones
		INNER JOIN
			(  
			select c.ZoneId,b.rgroupid ,count(a.CustId) Total,sum(a.cons1) [Total Consumption] 
			from rhist a 
			INNER JOIN rates b on a.RateId = b.RateId 
			INNER JOIN (select ZOneId,CustId,CustNum from cust) c on a.CustId = c.CustId
			INNER JOIN CBILL d
			on a.RhistId = d.RhistId
			where a.billdate=@billdate group by b.rgroupid,c.ZoneId
			) a 
			on Zones.ZoneId = a.ZoneId
		) b left join zones c on b.zoneno = c.zoneno 	 
		left join 
		(
			select zoneno,
			sum(rstatus) rstatus,
			sum(gstatus) gstatus,
			sum(istatus) istatus,
			sum(cstatus) cstatus,
			sum(bstatus) bstatus,
			sum(ostatus) ostatus
			from (
				select c.ZoneNo,
				case when rgroupid = 1 then count(status) end as [rstatus],
				case when rgroupid = 2 then count(status) end as [gstatus],
				case when rgroupid = 3 then count(status) end as [istatus],
				case when rgroupid = 4 then count(status) end as [cstatus],
				case when rgroupid = 5 then count(status) end as [bstatus],
				case when rgroupid = 6 then count(status) end as [ostatus]
			 from cust a 
			 INNER JOIN rates b on a.RateId=b.RateId 
			 INNER JOIN Zones c
			 on a.ZoneId = c.ZoneId
			 where a.status = 1 group by c.ZoneNo,rgroupid
			 ) a group by zoneno 
		 )
		d on c.zoneno=d.zoneno		
		group by c.zoneno,c.zonename

	order by c.zoneno
end
ELSE IF(@mode='2')
BEGIN
	select
	a.rgdesc [Classification],SUM(c.cons1) [Billed Volume],count(*) [Total Acct],AVG(c.cons1) [Avg. Cons]
	 from rategroup a left join rates b on a.RGroupid=b.rgroupid
	INNER JOIN
	(
		select RhistId,CustId,billdate,cons1,
		case when Rates.RateCd in('BYC','BYS') and cons1> 50 then 'C1' 
		when Rates.RateCd ='C12' and cons1>30 then 'C1'
		else Rates.RateCd end as rate 
		from rhist
		INNER JOIN Rates
		on Rhist.RateId = Rates.RateId
		where billdate = @billdate
	) c on b.RateCd=c.Rate 
	INNER JOIN Cbill d
	on c.RhistId = d.RhistId
	where d.billdate=@billdate
	group by a.rgdesc
end
else
begin

select c.bookno,c.area,

isnull(sum(Residential),0) as [Residential Billed Volume],
isnull(sum(d.rstatus),0) [Res. Active],
isnull(sum(rcount),0) as [Res. Billed Count],

isnull(sum(Government),0) as [Government Billed Volume],  
isnull(sum(d.gstatus),0) [Gov. Active],
isnull(sum(gcount),0) as  [Gov. Billed Count],

isnull(sum(Industrial),0) as [Industrial Billed Volume],
isnull(sum(d.istatus),0) [Ind. Active],
isnull(sum(icount),0) as  [Ind. Billed Count],

isnull(sum(Commercial),0) as [Commercial Billed Volume],
isnull(sum(d.cstatus),0) [Comm. Active],
isnull(sum(ccount),0) as [Comm. Billed Count],

isnull(sum(WholesaleBulk),0) as [WholesaleBulk Billed Volume],
isnull(sum(d.bstatus),0) [Bulk Active],
isnull(sum(wcount),0) as [Bulk Billed Count],

isnull(sum(Others),0) as [Others Billed Volume],
isnull(sum(d.ostatus),0) [Others Active],
isnull(sum(ocount),0) as [Others Billed Count],

isnull(sum(Residential),0) + isnull(sum(Government),0) + isnull(sum(Industrial),0) + isnull(sum(Commercial),0) + isnull(sum(WholesaleBulk),0) + isnull(sum(Others),0) [Billed Consumption GrandTotal],
isnull(sum(rcount),0) +isnull(sum(gcount),0)+isnull(sum(icount),0)+isnull(sum(ccount),0) + isnull(sum(wcount),0) + isnull(sum(ocount),0) TotalCount


     from
	 (
		 select BookId,
		 case when rgroupid = 1 then [total consumption] end as 'Residential',
		 case when rgroupid = 1 then total end as 'rcount',
		 case when rgroupid = 2 then [total consumption] end as 'Government',  
		 case when rgroupid = 2 then total end as 'gcount',  
		case when rgroupid = 3 then [total consumption] end as 'Industrial', 
		case when rgroupid = 3 then total end as 'icount', 
		case when rgroupid = 4 then [total consumption] end as 'Commercial',
		case when rgroupid = 4 then total end as 'ccount',
		case when rgroupid = 5 then [total consumption] end as 'WholesaleBulk', 
		case when rgroupid = 5 then total end as 'wcount', 
		case when rgroupid = 6 then [total consumption] end as 'Others', 
		case when rgroupid = 6 then total end as 'ocount', 

		Total from 
		(  
			select c.BookId,b.rgroupid ,count(a.CustId) Total,sum(a.cons1) [Total Consumption] 
			from rhist a 
			INNER JOIN rates b on a.RateId = b.RateId 
			INNER JOIN Books c
			on a.BookId = c.BookId
			INNER JOIN Rhist d
			on a.RhistId = d.RhistId
			where a.billdate=@billdate
			group by b.rgroupid,c.BookId
		) a 
	) b 
	left join books c on b.BookId = c.BookId 	 
	left join 
	(
		select BookId,
		sum(rstatus) rstatus,
		sum(gstatus) gstatus,
		sum(istatus) istatus,
		sum(cstatus) cstatus,
		sum(bstatus) bstatus,
		sum(ostatus) ostatus
		from 
		(
			select BookId,
			case when rgroupid = 1 then count(status) end as [rstatus],
			case when rgroupid = 2 then count(status) end as [gstatus],
			case when rgroupid = 3 then count(status) end as [istatus],
			case when rgroupid = 4 then count(status) end as [cstatus],
			case when rgroupid = 5 then count(status) end as [bstatus],
			case when rgroupid = 6 then count(status) end as [ostatus]
			from cust a left join rates b on a.RateId=b.RateId 
			left join members c on a.CustId=c.CustId
			where a.status = 1 group by BookId,rgroupid
		) a group by BookId 
	)d on c.BookId=d.BookId		
	group by c.bookno,c.area
	order by c.bookno
end
END
