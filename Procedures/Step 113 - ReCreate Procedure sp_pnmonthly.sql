ALTER PROCEDURE [dbo].[sp_pnmonthly]
	-- Add the parameters for the stored procedure here
	@CustId int,
	@billdate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @amort money
	declare @end_bal money
	declare @noofmonths int
	declare @start varchar(7)
	declare @end varchar(7)

	
	declare @end_watfee money
	declare @end_insfee money
	declare @end_penfee money
	declare @end_recfee money
	declare @end_servdep money
	declare @end_techfee money
	declare @end_waterm money
	declare @end_procfee money


	set @amort = isnull((select top 1 monthly_amort from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_bal = isnull((select top 1 end_bal from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @noofmonths = isnull((select top 1 number_months from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @start = isnull((select top 1 convert(varchar(7),dtransd,111) from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)

	
	set @end_watfee = isnull((select top 1 end_watfee from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_insfee = isnull((select top 1 end_insfee from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_penfee = isnull((select top 1 end_penfee from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_recfee = isnull((select top 1 end_recfee from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_servdep = isnull((select top 1 end_servdep from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_techfee = isnull((select top 1 end_techfee from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_waterm = isnull((select top 1 end_waterm from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)
	set @end_procfee = isnull((select top 1 end_procfee from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
	),0)

	--determine last month
	declare @ctr int
	set @ctr = 1
	while(@ctr <= @noofmonths)
	begin
		set @end = convert(varchar(7),DATEADD(month,(@ctr-1),convert(datetime,@start + '/01')),111)
		set @ctr = @ctr + 1
	end
	
	delete pn1_monthly from pn1_monthly
	INNER JOIN CUST
	on pn1_monthly.Custnum = Cust.Custnum
	and Cust.CustId = @CustId
	where Cust.CustId = @CustId

	while(@noofmonths > 0)
	begin
		if(@end_bal > 0)
		begin
			
			declare @amount money
			set @amount = case when @end_bal <= @amort then @end_bal else @amort end
			insert pn1_monthly(custnum,billdate,amount ,
			rwatfee,
			rinsfee ,
			rpenfee ,
			rrecfee,
			rservdep ,
			rtechfee ,
			rwaterm ,
			rprocfee)

			Select top 1 Cust.custnum
			,convert(varchar(7),DATEADD(month,(@noofmonths-1),convert(datetime,@start + '/01')),111)
			,@amount
			,rwatfee = case
			when isnull(@end_watfee,0) > 0
			and isnull(@amount,0) <= isnull(@end_watfee,0)
			then isnull(@amount,0)
			when isnull(@end_watfee,0) > 0
			and isnull(@amount,0) > isnull(@end_watfee,0)
			then isnull(@end_watfee,0)
			else 0 end
			,

			rinsfee = case
			when isnull(@end_insfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0))) <= isnull(@end_insfee,0)
			then (isnull(@amount,0) - (isnull(@end_watfee,0)))

			when isnull(@end_insfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0))) > isnull(@end_insfee,0)
			then isnull(@end_insfee,0)
			else 0
			end,

			rpenfee = case
			when isnull(@end_penfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0))) <= isnull(@end_penfee,0)
			then (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0)))

			when isnull(@end_penfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0))) > isnull(@end_penfee,0)
			then isnull(@end_penfee,0)
			else 0
			end,

			rrecfee = case
			when isnull(@end_recfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0))) <= isnull(@end_recfee,0)
			then (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0)))

			when isnull(@end_recfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0))) > isnull(@end_recfee,0)
			then isnull(@end_recfee,0)
			else 0
			end,

			rservdep = case
			when isnull(@end_servdep,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0))) <= isnull(@end_servdep,0)
			then (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0)))

			when isnull(@end_servdep,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0))) > isnull(@end_servdep,0)
			then isnull(@end_servdep,0)
			else 0
			end,

			rtechfee = case
			when isnull(@end_techfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0))) <= isnull(@end_techfee,0)
			then (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0)))

			when isnull(@end_techfee,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(end_recfee,0) + isnull(@end_servdep,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(end_recfee,0) + isnull(@end_servdep,0))) > isnull(@end_techfee,0)
			then isnull(@end_techfee,0)
			else 0
			end,

			rwaterm = case
			when isnull(@end_waterm,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0))) <= isnull(@end_waterm,0)
			then (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0)))

			when isnull(@end_waterm,0) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0))) > 0
			and (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0))) > isnull(end_waterm,0)
			then isnull(@end_waterm,0)
			else 0
			end,

			rprocfee = case
			when (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0) + isnull(@end_waterm,0))) > 0
			then (isnull(@amount,0) - (isnull(@end_watfee,0) + isnull(@end_insfee,0) + isnull(@end_penfee,0) + isnull(@end_recfee,0) + isnull(@end_servdep,0) + isnull(@end_techfee,0) + isnull(@end_waterm,0)))
			else 0
			end

			from pn1
			
			INNER JOIN CUST
			on pn1.CustId = Cust.CustId
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId
			and end_bal > 0

			set @end_bal = @end_bal - @amount

			Select @end_watfee = @end_watfee - rwatfee,
			@end_insfee  = @end_insfee - rinsfee,
			@end_penfee  = @end_penfee - rpenfee,
			@end_recfee  = @end_recfee - rrecfee,
			@end_servdep  = @end_servdep - rservdep,
			@end_techfee  = @end_techfee - rtechfee,
			@end_waterm  = @end_waterm - rwaterm,
			@end_procfee  = @end_procfee - rprocfee
			from pn1_monthly
			
			INNER JOIN CUST
			on pn1_monthly.custnum = Cust.Custnum
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId
			and billdate = (convert(varchar(7),DATEADD(month,(@noofmonths-1),convert(datetime,@start + '/01')),111))

		end
		else if(@end_bal <= 0)
		begin
			goto tapos 
		end
		set @noofmonths = @noofmonths - 1
	end
	tapos:


	declare @f_amount money
	declare @f_rwatfee money
	declare @f_rinsfee money
	declare @f_rpenfee money
	declare @f_rrecfee money
	declare @f_rservdep money
	declare @f_rtechfee money
	declare @f_rwaterm money
	declare @f_rprocfee money
	declare @f_monthly money

	--kevin
	--monthly amort base on pn duedate
	DELETE pn1_monthly From pn1_monthly 
			INNER JOIN CUST
			on pn1_monthly.custnum = Cust.Custnum
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId and billdate = (
	CASE WHEN RIGHT(CONVERT(VARCHAR(10),GETDATE(),111),2) < 
		(select RIGHT(CONVERT(VARCHAR(10),dduedate,111),2) From PN1 
			
			INNER JOIN CUST
			on pn1.CustId = Cust.CustId
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId
			and end_bal > 1
		and Cust.CustId = @custid and cpnno = (select max(cpnno) From PN1 
			
			INNER JOIN CUST
			on pn1.CustId = Cust.CustId
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId))
	AND CONVERT(VARCHAR(7),GETDATE(),111) <= 
		(select CONVERT(VARCHAR(7),dduedate,111) From PN1 
			
			INNER JOIN CUST
			on pn1.CustId = Cust.CustId
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId
			and end_bal > 1 and cpnno = (select max(cpnno) From PN1 
			
			INNER JOIN CUST
			on pn1.CustId = Cust.CustId
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId))
	THEN CONVERT(VARCHAR(7),GETDATE(),111) 
	ELSE '' END
	)

	
	if(exists(Select * from pn1_monthly
			
			INNER JOIN CUST
			on pn1_monthly.custnum = Cust.Custnum
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId
	and billdate <= @billdate))
	begin
	
		select @f_amount = sum(amount)
		,@f_rwatfee  = sum(rwatfee)
		, @f_rinsfee  = sum(rinsfee)
		, @f_rpenfee  = sum(rpenfee)
		, @f_rrecfee  = sum(rrecfee)
		, @f_rservdep  = sum(rservdep)
		, @f_rtechfee  = sum(rtechfee)
		, @f_rwaterm  = sum(rwaterm)
		, @f_rprocfee  = sum(rprocfee)
		from pn1_monthly
		INNER JOIN CUST
		on pn1_monthly.custnum = Cust.Custnum
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId
		and billdate <= @billdate
	end
	else
	begin
	
		select @f_amount = sum(amount)
		,@f_rwatfee  = sum(rwatfee)
		, @f_rinsfee  = sum(rinsfee)
		, @f_rpenfee  = sum(rpenfee)
		, @f_rrecfee  = sum(rrecfee)
		, @f_rservdep  = sum(rservdep)
		, @f_rtechfee  = sum(rtechfee)
		, @f_rwaterm  = sum(rwaterm)
		, @f_rprocfee  = sum(rprocfee)
		from pn1_monthly
		INNER JOIN CUST
		on pn1_monthly.custnum = Cust.Custnum
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId
		and billdate <= @billdate


	end


	update pn1
	set pn_remit = ISNULL(@f_amount,0)
	,rwatfee = ISNULL(@f_rwatfee,0)
	,rinsfee = ISNULL(@f_rinsfee,0)
	,rpenfee = ISNULL(@f_rpenfee,0)
	,rrecfee = ISNULL(@f_rrecfee,0)
	,rservdep = ISNULL(@f_rservdep,0)
	,rtechfee = ISNULL(@f_rtechfee,0)
	,rwaterm = ISNULL(@f_rwaterm,0)
	,rprocfee = ISNULL(@f_rprocfee,0)
	from pn1
			
	INNER JOIN CUST
	on pn1.CustId = Cust.CustId
	and Cust.CustId = @CustId
	where Cust.CustId = @CustId
	and end_bal > 0

	DECLARE @pnremit money
	SET @pnremit = (select case
				when pn_remit <= 1  and end_bal >= monthly_amort
					then monthly_amort
				when end_bal > pn_remit and pn_remit > 1
					then pn_remit
					else end_bal
				end
				from PN1
				INNER JOIN CUST
				on pn1.CustId = Cust.CustId
				and Cust.CustId = @CustId
				where Cust.CustId = @CustId
				and end_bal > 0)

	update PN1 set pn_remit = @pnremit,
				rwatfee = case
				when end_watfee >= @pnremit
					then @pnremit
					else end_watfee
				end,
				rprocfee = case
				when @pnremit > end_watfee + end_techfee + end_penfee
					then @pnremit - (end_watfee + end_techfee + end_penfee)
					else rprocfee
				end
	FROM PN1		
	INNER JOIN CUST
	on pn1.CustId = Cust.CustId
	and Cust.CustId = @CustId
	where Cust.CustId = @CustId
	and end_bal > 0
END
