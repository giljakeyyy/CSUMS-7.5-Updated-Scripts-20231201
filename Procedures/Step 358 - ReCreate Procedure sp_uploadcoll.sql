ALTER PROCEDURE [dbo].[sp_uploadcoll]
	-- Add the parameters for the stored procedure here
	@CustNum varchar(30),
	@paydate as varchar(100),
	@payamnt money,
	@subtot1 money,
	@subtot2 money,
	@subtot3 money,
	@subtot4 money,
	@subtot5 money,
	@subtot6 money,
	@subtot7 money,
	@subtot8 money,
	@subtot9 money,
	@subtot10 money,
	@subtot12 money,
	@tax1 money,
	@tax2 money,
	@pnamount money,
	@pn1 money,--procfee
	@pn2 money,--watfee
	@pn3 money,--recfee
	@pn4 money,--meter
	@pn5 money,--penalty
	@pn6 money,--serv dep
	@pn7 money,--intallation
	@pn8 money,--technical
	@pymntmode varchar(5),
	@rcvdby varchar(50),
	@ornum varchar(100),
	@oldorno varchar(100),
	@remark varchar(100),
	@earlybird money = 0,
	@JOMaterials money = 0,
	@JOOthers money = 0,
	@JOGDeposit money = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @Custid int
	set @Custid = isnull((Select CustId from Cust where CustNum = @CustNum),0)
	declare @result varchar(100)
	declare @cpnno as varchar(20)
	set @cpnno = ''
	set @cpnno = isnull
	(
		(
			Select top 1 cpnno from PN1
			where end_bal > 0 and CustId = @CustId
			order by ddate
		),''
	)
	IF((@subtot1 + @subtot2 + @subtot3 + @subtot4 + @subtot5 + @subtot6 + @subtot7 + @subtot8
	 + @subtot12 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8 + @JOMaterials + @JOOthers + @JOGDeposit > 0 and @ornum = '') or (@subtot9 + @pn1 > 0 and @oldorno = ''))
	 BEGIN
		set @result = 'No OR'
	 END
	 ELSE IF(exists(Select PymntNum from cpaym where PymntMode = @pymntmode and PayDate = @paydate and CustId = @CustId))
	 BEGIN
		set @result = 'Already Exists'
	 END
	 ELSE IF(exists(Select PymntNum from cpaym where (ORNum = @ornum and @ornum <> '' and ISNUMERIC(@ornum) = 1 and convert(numeric(18,2),@ornum) <> 0.00) or (oldorno = @oldorno and @oldorno <> '' and ISNUMERIC(@oldorno) = 1 and convert(numeric(18,2),@oldorno) <> 0.00)))
	 BEGIN
		set @result = 'OR Already Used'
	 END
	 ELSE IF(convert(numeric(18,2),@payamnt) <> convert(numeric(18,2),(@subtot1 + @subtot2 + @subtot3 + @subtot4 + @subtot5 + @subtot6 + @subtot7 + @subtot8
	 + @subtot9+ @subtot12 + @pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8 + @JOMaterials + @JOOthers + @jogdeposit) - (@subtot10)))
	 BEGIN
		set @result = 'Error in Saving'
	 END
	 ELSE IF(((@subtot1 - (@tax1 + @earlybird)) < 0 or (@subtot2 - @tax2) < 0 or @subtot3 < 0 or @subtot4 < 0 or @subtot5 < 0 or @subtot6 < 0 or @subtot7 < 0 or @subtot8
	 < 0 or @subtot9 < 0 or @subtot12 < 0 or @pn1 < 0 or @pn2 < 0 or @pn3 < 0 or @pn4 < 0 or @pn5 < 0 or @pn6 < 0 or @pn7 < 0 or @pn8 < 0 or @JOMaterials < 0 or @JOOthers < 0 or @JOGDeposit < 0))
	 BEGIN
		set @result = 'Error in Saving'
	 END
	 ELSE IF(not exists(Select CustNum from cust where CustId = @CustId union Select applnum as custnum from [Application] where applnum = @custnum))
	 BEGIN
		set @result = 'Error in Saving'
	 END
	 ELSE
	 BEGIN
		
		IF(@subtot1 + @Subtot2 + @Subtot3 + @subtot4 + @subtot5 + @subtot6 + @subtot7 + @subtot8 + @subtot9 + @subtot12 > 0)
		BEGIN
		
			declare @table table (pymtnum int primary key)

			insert cpaym
			(
				CustId,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty
				,subtot1,Subtot2,Subtot3,subtot4,subtot5,subtot6,subtot7,subtot8,subtot9
				,subtot10,subtot11,subtot12,tax1,tax2,PayDate,PymntDtl,ORNum,RcvdBy,oldorno
				,ntype,capproved
				,pnno,rrecfee,rwaterm,rpenfee,rservdep,rprocfee,rinsfee,rtechfee,rwatfee,pn_amount,subtot13,subtot14,CreatedDate
			)
			OUTPUT Inserted.PymntNum into @table(pymtnum)
			values
			(
				@CustId,'',@PymntMode,1,1,@PayAmnt - (@JOMaterials + @JOOthers + @jogdeposit),0
				,@subtot1 - (@tax1 + @earlybird),(@Subtot2) - @tax2,@Subtot3,@subtot4,@subtot5,
				@subtot6,@subtot7,@subtot8,@subtot9,@tax1 + @tax2 + @earlybird,0,@subtot12,
				@tax1 + @earlybird,@tax2,@PayDate,'Date Uploaded:' + convert(varchar(100),
				getdate(),111),@ORNum,@RcvdBy,@oldorno,
				case 
				when @earlybird > 0 then 3 
				when @subtot10 > 0 then 1 else 0 end
				,@rcvdby,@cpnno,@pn3,@pn4,@pn5,@pn6,@pn1,@pn7,@pn8,@pn2,
				(@pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8),0,0,GETDATE()
			)

		
			IF(@tax1 > 0)
			BEGIN	
				insert Cpaym_Discount(pymntnum,nid,value)
				select *,isnull((Select top 1 nid from Cashier_Discount where [description] like '%Cur%' and [description] like '%senior%'),1),@tax1 
				from @table
			END
			IF(@tax2 > 0)
			BEGIN	
				insert Cpaym_Discount(pymntnum,nid,value)
				select *,isnull((Select top 1 nid from Cashier_Discount where [description] like '%Arr%' and [description] like '%senior%'),1),@tax2
				from @table
			END
			IF(@earlybird > 0)
			BEGIN	
				insert Cpaym_Discount(pymntnum,nid,value)
				select *,isnull((Select top 1 nid from Cashier_Discount where [description] like '%Cur%' and [description] like '%early%'),1),@earlybird
				from @table
			END

			update b
			set billstat = 3
			from cust a
			inner join cbill b
			on a.CustId = b.CustId
			and a.BillNum = b.BillNum
			and b.BillStat <> 1
			and a.CustId = @CustId
			where a.CustId = b.CustId
			and a.BillNum = b.BillNum
			and b.BillStat <> 1
			and a.CustId = @CustId


			update PN1
			set end_bal = end_bal - (@pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8),
			end_recfee = end_recfee - @pn3
			,end_waterm = end_waterm - @pn4
			,end_penfee = end_penfee - @pn5
			,end_servdep = end_servdep - @pn6
			,end_procfee = end_procfee - @pn1
			,end_insfee = end_insfee - @pn7
			,end_techfee = end_techfee - @pn8
			,end_watfee = end_watfee - @pn2

			where CustId = @CustId
			and end_bal > 0
			and (@pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8) > 0
		END

		IF(@JOMaterials + @JOOthers + @JOGDeposit > 0)
		BEGIN
			insert cpaym2
			(
				custnum,cname,PymntMode,PymntStat,PayAmnt,Subtot1,Subtot2,PayDate,PymntDtl,ORNum,RcvdBy,subtot3,CreatedDate
			)
			values
			(
				@custnum,'',@pymntmode,1,@JOMaterials + @JOOthers + @JOGDeposit,@JOMaterials,@JOOthers,@paydate,@remark,@ornum,@rcvdby,@JOGDeposit,GETDATE()
			)
		END

		set @result = 'Saved'
	 END
	select @result as result
END
