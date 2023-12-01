ALTER PROCEDURE [dbo].[Cashier_Payment]
	
	@CustId int,
	@subtot1 money,	
	@subtot2 money,	
	@subtot3 money,
	@subtot4 money,
	@subtot5 money,	
	@subtot6 money,	
	@subtot7 money,
	@subtot8 money,
	@subtot9 money,	
	@subtot11 money,	
	@subtot12 money,		
	@pn money,
	@cur_disc money,
	@arr_disc money,
	@rcvdby varchar(12),
	@capproved char(10),	
	@pymntmode varchar(2),
	@pymnttyp varchar(1),
	@ornum varchar(20),
	@oldorno varchar(20),
	@ntype numeric(5,1),
	@pymntdtl varchar(120),
	@subtot1hoa money,--advance subtot13
	@subtot2hoa money,--advance subtot14
	@subtot3hoa money,
	@subtot6hoa money,
	@subtot7hoa money,
	@subtot8hoa money,
	@paydate Date
	
	--added
	,
	@wdorletter varchar(10) = ''

	--end
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @payamnt money
	declare @subtot10 money
	
	declare @rrecfee money
	declare @rwaterm money
	declare @rpenfee money
	declare @rservdep money
	declare @rprocfee money
	declare @rinsfee money
	declare @rtechfee money
	declare @rwatfee money
	declare @cpnno as varchar(50)
	declare @principal_amt money
	declare @endwatfee money
	declare @endinsfee money
	declare @endpenfee money
	declare @endrecfee money
	declare @endservdep money
	declare @endtechfee money
	declare @endwaterm money
	declare @endprocfee money

	set @cpnno = ''
	set @rrecfee = 0
	set @rwaterm = 0
	set @rpenfee = 0
	set @rservdep = 0
	set @rprocfee = 0
	set @rinsfee = 0
	set @rtechfee = 0
	set @rwatfee = 0
	set @principal_amt = @pn
	set @endwatfee = 0

	if(@pn > 0)
	begin

			set @cpnno = (Select top 1 cpnno from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where end_bal > 0 and PN1.CustId = @CustId
			order by ddate)

			
			set @rwatfee = (Select top 1 isnull(rwatfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endwatfee = (Select top 1 isnull(end_watfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endinsfee = (Select top 1 isnull(end_insfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endpenfee = (Select top 1 isnull(end_penfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endrecfee = (Select top 1 isnull(end_recfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endservdep = (Select top 1 isnull(end_servdep,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endtechfee = (Select top 1 isnull(end_techfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endwaterm = (Select top 1 isnull(end_waterm,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			set @endprocfee = (Select top 1 isnull(end_procfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rwatfee = case
			--when @rwatfee > 0
			--and @principal_amt > 0
			--and @rwatfee <= @principal_amt
			--then @rwatfee
			--when @rwatfee > 0
			--and @principal_amt > 0
			--and @rwatfee > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rwatfee = case when @endwatfee = 0
									then @endwatfee
								when @endwatfee > 0 and (@endwatfee - @principal_amt) > 0
									then @principal_amt
								when @endwatfee > 0 and (@endwatfee - @principal_amt) <= 0
									then @endwatfee
								else 0 end

			set @principal_amt = @principal_amt - @rwatfee
			
			set @rinsfee = (Select top 1 isnull(rinsfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rinsfee = case
			--when @rinsfee > 0
			--and @principal_amt > 0
			--and @rinsfee <= @principal_amt
			--then @rinsfee
			--when @rinsfee > 0
			--and @principal_amt > 0
			--and @rinsfee > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rinsfee = 0 /*case when @endinsfee = 0
									then @endinsfee
								when @endinsfee > 0 and (@endinsfee - @principal_amt) > 0
									then @principal_amt
								when @endinsfee > 0 and (@endinsfee - @principal_amt) <= 0
									then @endinsfee
								else 0 end*/

			set @principal_amt = @principal_amt - @rinsfee
			
			set @rpenfee = (Select top 1 isnull(rpenfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rpenfee = case
			--when @rpenfee > 0
			--and @principal_amt > 0
			--and @rpenfee <= @principal_amt
			--then @rpenfee
			--when @rpenfee > 0
			--and @principal_amt > 0
			--and @rpenfee > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rpenfee = case when @endpenfee = 0
									then @endpenfee
								when @endpenfee > 0 and (@endpenfee - @principal_amt) > 0
									then @principal_amt
								when @endpenfee > 0 and (@endpenfee - @principal_amt) <= 0
									then @endpenfee
								else 0 end

			set @principal_amt = @principal_amt - @rpenfee
			
			set @rrecfee = (Select top 1 isnull(rrecfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rrecfee = case
			--when @rrecfee > 0
			--and @principal_amt > 0
			--and @rrecfee <= @principal_amt
			--then @rrecfee
			--when @rrecfee > 0
			--and @principal_amt > 0
			--and @rrecfee > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rrecfee = 0 /*case when @endrecfee = 0
									then @endrecfee
								when @endrecfee > 0 and (@endrecfee - @principal_amt) > 0
									then @principal_amt
								when @endrecfee > 0 and (@endrecfee - @principal_amt) <= 0
									then @endrecfee
								else 0 end*/

			set @principal_amt = @principal_amt - @rrecfee
			
			set @rservdep = (Select top 1 isnull(rservdep,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rservdep = case
			--when @rservdep > 0
			--and @principal_amt > 0
			--and @rservdep <= @principal_amt
			--then @rservdep
			--when @rservdep > 0
			--and @principal_amt > 0
			--and @rservdep > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rservdep = 0 /*case when @endservdep = 0
									then @endservdep
								when @endservdep > 0 and (@endservdep - @principal_amt) > 0
									then @principal_amt
								when @endservdep > 0 and (@endservdep - @principal_amt) <= 0
									then @endservdep
								else 0 end*/

			set @principal_amt = @principal_amt - @rservdep
			
			set @rtechfee = (Select top 1 isnull(rtechfee,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rtechfee = case
			--when @rtechfee > 0
			--and @principal_amt > 0
			--and @rtechfee <= @principal_amt
			--then @rtechfee
			--when @rtechfee > 0
			--and @principal_amt > 0
			--and @rtechfee > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rtechfee = case when @endtechfee = 0
									then @endtechfee
								when @endtechfee > 0 and (@endtechfee - @principal_amt) > 0
									then @principal_amt
								when @endtechfee > 0 and (@endtechfee - @principal_amt) <= 0
									then @endtechfee
								else 0 end

			set @principal_amt = @principal_amt - @rtechfee
			
			set @rwaterm = (Select top 1 isnull(rwaterm,0) from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId
			order by ddate)

			--set @rwaterm = case
			--when @rwaterm > 0
			--and @principal_amt > 0
			--and @rwaterm <= @principal_amt
			--then @rwaterm
			--when @rwaterm > 0
			--and @principal_amt > 0
			--and @rwaterm > @principal_amt
			--then @principal_amt
			--else 0 end

			set @rwaterm = 0 /*case when @endwaterm = 0
									then @endwaterm
								when @endwaterm > 0 and (@endwaterm - @principal_amt) > 0
									then @principal_amt
								when @endwaterm > 0 and (@endwaterm - @principal_amt) <= 0
									then @endwaterm
								else 0 end*/

			set @principal_amt = @principal_amt - @rwaterm

			set @rprocfee = case when @principal_amt > 0 then @principal_amt else 0 end

			update pn1
			set end_bal = end_bal - @pn,
			end_watfee = end_watfee - @rwatfee,

			end_insfee = end_insfee - @rinsfee,

			end_penfee = end_penfee - @rpenfee,

			end_recfee = end_recfee - @rrecfee,

			end_servdep = end_servdep - @rservdep,

			end_techfee = end_techfee - @rtechfee,

			end_waterm = end_waterm - @rwaterm,

			end_procfee = end_procfee - @rprocfee
			from PN1
			INNER JOIN CUST
			on PN1.CustId = Cust.CustId
			where cpnno = @cpnno and PN1.CustId = @CustId

			--kevin
			DECLARE @Billdate VARCHAR(7)
			SET @Billdate =(SELECT CONVERT(VARCHAR(7),GETDATE(),111))

			EXEC [sp_pnmonthly] @CustId,@Billdate
			--kevin
	end

	
	set @subtot10 = isnull(@cur_disc,0) + isnull(@arr_disc,0);
	set @payamnt = isnull(@subtot1,0)+isnull(@subtot2,0)+isnull(@subtot3,0)+isnull(@subtot4,0)+isnull(@subtot5,0)+isnull(@subtot6,0)+isnull(@subtot7,0)
					+ isnull(@subtot8,0)+isnull(@subtot9,0)+isnull(@subtot11,0)+isnull(@subtot12,0)
					+ isnull(@subtot1hoa,0)+isnull(@subtot2hoa,0)+isnull(@pn,0) - isnull(@subtot10,0) ;
	
	if(isnull(@subtot1,0)>0)
	begin
	set @subtot1 = isnull(@subtot1,0) - isnull(@cur_disc,0)
	end
	--if(isnull(@subtot2,0)>0)
	--begin
	set @subtot2 = isnull(@subtot2,0) - isnull(@arr_disc,0)
	--end
	
	--if(isnull(@subtot1,0)+isnull(@subtot2,0)=0 and isnull(@subtot3,0)>0)
	if(isnull(@subtot1,0)=0 and isnull(@subtot3,0)>0)
	begin
	set @subtot3 = @subtot3 - @cur_disc
	end


	declare @table table (pymtnum int primary key)


	insert cpaym(CustId,pymntmode,pymnttyp,pymntstat,payamnt,
	subtot1,subtot2,subtot3,subtot4,subtot5,subtot6,subtot7,subtot8,subtot9,
	subtot10,ntype,tax1,tax2,subtot11,subtot12,RcvdBy,pymntdtl,ornum,oldorno,capproved,paydate
	,pnno,rrecfee,rwaterm,rpenfee,rservdep,rprocfee,rinsfee,rtechfee,rwatfee,pn_amount,Subtot13,Subtot14,wdorletter,CreatedDate)
	OUTPUT Inserted.PymntNum into @table(pymtnum)
	values(@CustId,@pymntmode,@pymnttyp,'1',@payamnt,
	@subtot1,@subtot2,@subtot3,@subtot4,@subtot5,@subtot6,@subtot7,@subtot8,@subtot9,
	@subtot10,@ntype,@cur_disc,@arr_disc,@subtot11,@subtot12,@rcvdby,@pymntdtl,@ornum,@oldorno,@capproved,convert(varchar(11),@paydate,111)
	
	,@cpnno,@rrecfee,@rwaterm,@rpenfee,@rservdep,@rprocfee,@rinsfee,@rtechfee,@rwatfee,@pn
	,@subtot1hoa,@subtot2hoa, @wdorletter,GETDATE()
	)
	
	if(@pn > 0)
	begin
		insert pn2(cpnno,dtransd,crefno,cparticular,amount,tcode,balance,cremarks,username,userdate,pymntmode,rrecfee,rwaterm,rpenfee,rservdep,rprocfee,rinsfee,rtechfee,rwatfee)
		select @cpnno,@paydate,(Select * from @table),'',@pn,1,(Select isnull(end_bal,0) 
		from pn1 
		INNER JOIN CUST
		on PN1.CustId = Cust.CustId
		where cpnno = @cpnno and PN1.CustId = @CustId)
		,@pymntdtl,@rcvdby,getdate(),'1',@rrecfee,@rwaterm,@rpenfee,@rservdep,@rprocfee,@rinsfee,@rtechfee,@rwatfee
	end
	
	
	select * from @table
END

GO


