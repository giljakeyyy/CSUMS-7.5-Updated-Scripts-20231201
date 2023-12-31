ALTER PROCEDURE [dbo].[sp_computeunreadaverage]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@bookno varchar(10),
	@username varchar(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select a.CustId,a.CustNum,c.BookNo,b.SeqNo,h.RateCd as Rate,@BillDate as billdate,convert(varchar(20),getdate(),111) as Rdate
	,'12:00 ' Rtime,b.Pread1,replace(convert(varchar(100),b.pread1 + isnull(b.avecon1,0)),'.00','') Read1,CONVERT(DECIMAL(18,0),isnull(b.avecon1,0)) Cons1
	,'' Pread2,'' Read2,'' Cons2,
	'' RangeCd,1 Tries,'' MissCd,'' WarnCd,'' FF1Cd,'' FF2Cd,'' FF3Cd,'Averaged by ' + @username Remark
	,nbasic = 
	CASE
	WHEN isnull(b.avecon1,0) <= 10 THEN
		f.minbill 
	WHEN isnull(b.avecon1,0) > 10 and isnull(b.avecon1,0) <= 20 THEN
		((isnull(b.avecon1,0) - 10) * f.rate1) + f.minbill
	WHEN isnull(b.avecon1,0) > 20 and isnull(b.avecon1,0) <=30 THEN
		((isnull(b.avecon1,0) - 20) * f.rate2) + f.minbill + (f.rate1 * 10)
	WHEN isnull(b.avecon1,0) > 30 and isnull(b.avecon1,0) <=40 THEN
		((isnull(b.avecon1,0) - 30) * f.rate3) + f.minbill + (f.rate1 * 10) + (f.rate2 * 10)
	WHEN isnull(b.avecon1,0) > 40 and isnull(b.avecon1,0) <=50  THEN
		((isnull(b.avecon1,0) - 40) * f.rate4) + f.minbill + (f.rate1 * 10) + (f.rate2 * 10) + (f.rate3 * 10)
	WHEN isnull(b.avecon1,0) > 50 THEN
		((isnull(b.avecon1,0) - 50) * f.rate5) + f.minbill + (f.rate1 * 10) + (f.rate2 * 10) + (f.rate3 * 10) + (f.rate4 * 10)
		END

	
	,d.duedate as DueDate,convert(varchar(20),d.fromdate,111) + '-' + convert(varchar(20),d.todate,111) as BillPeriod
	,Arrears = isnull(e.[Water Balance],0),0 as OldArrears1 
	from
	Cust a
	Inner Join Members b
	on a.CustId = b.CustId
	Inner Join Books c
	on b.BookId = c.BookId
	INNER JOIN BillingSchedule d
	on d.billdate = @billdate
	and b.BookId = d.BookId
	left join vw_ledger e
	on a.CustId = e.CustId
	INNER JOIN
	(
		select distinct RateId,ZoneId,minbill,rate1,rate2,rate3,rate4,rate5 from bill
	) f
	on a.RateId = f.rateId
	and a.zoneId = f.ZoneId 
	left join Rhist g
	on a.CustId = g.CustId
	and g.BillDate = @billdate
	left join rates h
	on a.rateid = h.rateid
	where a.status = 1
	and g.RhistId is null
	and c.bookno = @bookno
END
