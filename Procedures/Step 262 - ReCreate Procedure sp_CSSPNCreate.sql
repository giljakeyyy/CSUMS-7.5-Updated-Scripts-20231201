ALTER PROCEDURE [dbo].[sp_CSSPNCreate]
	-- Add the parameters for the stored procedure here
		@ddate datetime,
		@CustId int,
		@npn_amt numeric(18,2),	
		@dduedate datetime,		
		@monthly_amort numeric(18,2),
		@number_months int,
		@username char(10),
		@pn_remit numeric(18,2),
		@nrecfee money,
		@nwaterm money,
		@npenfee money,
		@nservdep money,
		@nprocfee money,
		@ninsfee money,
		@ntechfee money,
		@nwatfee money,
		@remarks varchar(50),		
		@cpnno1 char(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		IF (len(@cpnno1)=0)
		BEGIN
			declare @cpnno int;

			set @cpnno = (select isnull(max(convert(int, ltrim(rtrim(cpnno)))),0) + 1 from pn1 where isnumeric(cpnno)=1)

			IF(@ntechfee>0)
			BEGIN
				update a set a.cpnno = @cpnno 
				From Application_otherfees a
				LEFT JOIN Cust b 
				on (a.Applnum=b.Applnum or a.Applnum=b.custnum) 
				where cpnno is null 
				and a.totpn>0 and b.CustId = @CustId
			END
		
			INSERT pn1
			(
				cpnno,ddate,dtransd,CustId,npn_amt,beg_bal,dduedate,penalty,end_bal,monthly_amort,number_months,username,userdate,pn_remit,
				nrecfee,nwaterm,npenfee,nservdep,nprocfee,ninsfee,ntechfee,nwatfee,cremarks,
				end_recfee,end_waterm,end_penfee,end_servdep,end_procfee,end_insfee,end_techfee,end_watfee,
				lpaid,lcompute,rrecfee,rwaterm,rpenfee,rservdep,rprocfee,rinsfee,rtechfee,rwatfee,
				nint_amt,lsubmit,nrate,cclass
			)
			OUTPUT inserted.cpnno
			values(@cpnno,@ddate,@ddate,@CustId,@npn_amt,@npn_amt,@dduedate,0.00,@npn_amt,@monthly_amort,@number_months,@username,getdate(),@pn_remit,
			@nrecfee,@nwaterm,@npenfee,@nservdep,@nprocfee,@ninsfee,@ntechfee,@nwatfee,@remarks,
			@nrecfee,@nwaterm,@npenfee,@nservdep,@nprocfee,@ninsfee,@ntechfee,@nwatfee,
			0,0,0,0,0,0,0,0,0,0,
			0,0,0,''
			)
		END
		ELSE IF(@ntechfee>0)
		BEGIN
			update a set a.cpnno = @cpnno1 from	Application_OtherFees a left join		
			cust b on (a.Applnum=b.Applnum or a.Applnum=b.custnum) where cpnno is null and a.totpn>0 and b.CustId = @CustId
		END
		update pn1 set npn_amt = @npn_amt,beg_bal = @npn_amt,dduedate= @dduedate,end_bal=@npn_amt,
		monthly_amort = @monthly_amort,number_months=@number_months,username=@username,
		pn_remit=@pn_remit,nrecfee=@nrecfee,nwaterm=@nwaterm,npenfee=@npenfee,nservdep=@nservdep,
		nprocfee=@nprocfee,ninsfee=@ninsfee,ntechfee=@ntechfee,nwatfee=@nwatfee,cremarks=@remarks
		,end_recfee=@nrecfee,end_waterm=@nwaterm,end_penfee=@npenfee,end_servdep=@nservdep,
		end_procfee=@nprocfee,end_insfee=@ninsfee,end_techfee=@ntechfee,end_watfee=@nwatfee
		where cpnno = @cpnno1

		update b
		set pn_remit = case
		when monthly_amort <= end_bal
		then monthly_amort
		else end_bal
		end

		,rwatfee = case
		when isnull(end_watfee,0) > 0
		and isnull(monthly_amort,0) <= isnull(end_watfee,0)
		then isnull(monthly_amort,0)
		when isnull(end_watfee,0) > 0
		and isnull(monthly_amort,0) > isnull(end_watfee,0)
		then isnull(end_watfee,0)
		else 0 end
		,

		rinsfee = case
		when isnull(end_insfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0))) <= isnull(end_insfee,0)
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0)))

		when isnull(end_insfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0))) > isnull(end_insfee,0)
		then isnull(end_insfee,0)
		else 0
		end,

		rpenfee = case
		when isnull(end_penfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0))) <= isnull(end_penfee,0)
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0)))

		when isnull(end_penfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0))) > isnull(end_penfee,0)
		then isnull(end_penfee,0)
		else 0
		end,

		rrecfee = case
		when isnull(end_recfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0))) <= isnull(end_recfee,0)
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0)))

		when isnull(end_recfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0))) > isnull(end_recfee,0)
		then isnull(end_recfee,0)
		else 0
		end,

		rservdep = case
		when isnull(end_servdep,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0))) <= isnull(end_servdep,0)
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0)))

		when isnull(end_servdep,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0))) > isnull(end_servdep,0)
		then isnull(end_servdep,0)
		else 0
		end,

		rtechfee = case
		when isnull(end_techfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0))) <= isnull(end_techfee,0)
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0)))

		when isnull(end_techfee,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0))) > isnull(end_techfee,0)
		then isnull(end_techfee,0)
		else 0
		end,

		rwaterm = case
		when isnull(end_waterm,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0))) <= isnull(end_waterm,0)
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0)))

		when isnull(end_waterm,0) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0))) > 0
		and (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0))) > isnull(end_waterm,0)
		then isnull(end_waterm,0)
		else 0
		end,

		rprocfee = case
		when (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0) + isnull(end_waterm,0))) > 0
		then (isnull(monthly_amort,0) - (isnull(end_watfee,0) + isnull(end_insfee,0) + isnull(end_penfee,0) + isnull(end_recfee,0) + isnull(end_servdep,0) + isnull(end_techfee,0) + isnull(end_waterm,0)))
		else 0
		end
		
		from cust a
		inner join pn1 b
		on a.CustId = b.CustId
		and b.end_bal > 0   
END
