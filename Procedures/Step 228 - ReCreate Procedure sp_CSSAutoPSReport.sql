ALTER PROCEDURE [dbo].[sp_CSSAutoPSReport]
		@BookId int,
		@ZoneId int,
		@CustName varchar(100),
		@Billdate varchar(7),
		@rate varchar(2)
AS
BEGIN
	
	SET NOCOUNT ON;

	Select e.bookno,a.billnum,b.custnum,a.billdate,a.amount1,a.amount2,b.custname,b.bilstadd,b.bilctadd,f.zoneno,d.RateCd,d.ratename 
	FROM CbillOthers a 
	INNER JOIN cust b on a.CustId=b.CustId
	INNER JOIN members c on b.CustId=c.CustId
	INNER JOIN rates d on b.RateId = d.RateId
	INNER JOIN Books e on c.BookId = e.BookId
	INNER JOIN Zones f on b.ZoneId = f.ZoneId
	where a.BillDate= @Billdate
	--Add BookNo as Filter
	and (@BookId = 0 or @BookId = c.BookId)
	--Add Zoneno as Filter
	and (@ZoneId <=0 or @ZoneId = b.ZoneId)
	--Add Name as Filter
	and (@Custname = '' or b.CustName like '%' + @CustName + '%')
	--Add Rate as Filter
	and (len(@rate) <= 0 or d.RateCd = @Rate)

END


