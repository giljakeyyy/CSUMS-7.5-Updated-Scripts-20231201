ALTER PROCEDURE [dbo].[jva_currenteff](@billdate1 varchar(7))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	declare @billdate varchar(7)
	set @billdate = @billdate1
	declare	@paystat varchar(1)
	set @paystat = 5
	SET NOCOUNT ON;
	
	select d.ratename RateName,d.ratecd RateCode,Count(b.BillNum) TotalBilled,
	isnull(sum(b.Subtot1),0) [Current Bill Amount],
	isnull(sum(x.subtot1+x.subtot3),0) [Current Pay Amount],
	case when sum(b.Subtot1) > 0 and isnull(sum(x.subtot1+x.subtot3),0) > 0  then
	 (sum(x.subtot1+x.subtot3) / sum(b.SubTot1)) * 100 
	else 0 
	 end as [Current Efficiency (%)]

	from cust a 
	INNER JOIN Rhist c 
	on a.CustId = c.CustId
	and c.BillDate = @billdate
	INNER JOIN Cbill b
	on b.RhistId = c.RhistId
	left join Rates d 
	on c.RateId = d.RateId
	LEFT JOIN Cpaym x 
	on x.CustId = a.CustId
	and left(x.PayDate,7) = @billdate

	group by d.ratename,d.ratecd



 
 
END



