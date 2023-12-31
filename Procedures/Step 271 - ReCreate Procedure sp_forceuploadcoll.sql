ALTER PROCEDURE [dbo].[sp_forceuploadcoll]
	-- Add the parameters for the stored procedure here
	@custnum as varchar(100),
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
	@earlybird money = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @result varchar(100)

	if((@subtot1 + @subtot2 + @subtot3 + @subtot4 + @subtot5 + @subtot6 + @subtot7 + @subtot8
	 + @subtot12 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8 > 0 and @ornum = '') or (@subtot9 + @pn1 > 0 and @oldorno = ''))
	 begin
		set @result = 'No OR'
	 end
	 --else if(exists(Select * from cpaym where PymntMode = @pymntmode and PayDate = @paydate and CustNum = @custnum))
	 --begin
		--set @result = 'Already Exists'
	 --end
	 else if(exists(Select * from cpaym where (ORNum = @ornum and @ornum <> '' and ISNUMERIC(@ornum) = 1 and convert(numeric(18,2),@ornum) <> 0.00) or (oldorno = @oldorno and @oldorno <> '' and ISNUMERIC(@oldorno) = 1 and convert(numeric(18,2),@oldorno) <> 0.00)))
	 begin
		set @result = 'OR Already Used'
	 end
	 else if(convert(numeric(18,2),@payamnt) <> convert(numeric(18,2),(@subtot1 + @subtot2 + @subtot3 + @subtot4 + @subtot5 + @subtot6 + @subtot7 + @subtot8
	 + @subtot9+ @subtot12 + @pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8) - @subtot10))
	 begin
		set @result = 'Error in Saving'
	 end
	 else if(((@subtot1 - (@tax1 + @earlybird)) < 0 or (@subtot2 - @tax2) < 0 or @subtot3 < 0 or @subtot4 < 0 or @subtot5 < 0 or @subtot6 < 0 or @subtot7 < 0 or @subtot8
	 < 0 or @subtot9 < 0 or @subtot12 < 0 or @pn1 < 0 or @pn2 < 0 or @pn3 < 0 or @pn4 < 0 or @pn5 < 0 or @pn6 < 0 or @pn7 < 0 or @pn8 < 0))
	 begin
		set @result = 'Error in Saving'
	 end
	 else if(not exists(Select custnum from cust where custnum = @custnum))
	 begin
		set @result = 'Error in Saving'
	 end
	 else
	 begin
		
		declare @CustId int
		set @CustId = isnull((Select Custid from Cust where CustNum = @custnum),0)
		declare @cpnno as varchar(20)
		set @cpnno = ''
		set @cpnno = isnull((Select top 1 cpnno from PN1
				where end_bal > 0 and CustId = @CustId
				order by ddate),'')

		declare @table table (pymtnum int primary key)
		Select top 1 * from cpaym
		insert cpaym(CustId,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty
		,subtot1,Subtot2,Subtot3,subtot4,subtot5,subtot6,subtot7,subtot8,subtot9
		,subtot10,subtot11,subtot12,tax1,tax2,PayDate,PymntDtl,ORNum,RcvdBy,oldorno
		,ntype,capproved
		,pnno,rrecfee,rwaterm,rpenfee,rservdep,rprocfee,rinsfee,rtechfee,rwatfee,pn_amount,subtot13,subtot14)
		OUTPUT Inserted.PymntNum into @table(pymtnum)
		values(
		@CustId,'',@PymntMode,1,1,@PayAmnt,0
		,@subtot1 - (@tax1+ @earlybird),(@Subtot2 + (@pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8)) - @tax2,@Subtot3,@subtot4,@subtot5,@subtot6,@subtot7,@subtot8,@subtot9 + @pn1
		,@tax1 + @tax2 + @earlybird,0,@subtot12,@tax1 + @earlybird,@tax2,@PayDate,'Date Uploaded:' + convert(varchar(100),getdate(),111),@ORNum,@RcvdBy,@oldorno
		,case when @earlybird > 0 then 3 when @subtot10 > 0 then 1 else 0 end,@rcvdby
		,@cpnno,@pn3,@pn4,@pn5,@pn6,@pn1,@pn7,@pn8,@pn2,(@pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8),0,0)
		
		if(@tax1 > 0)
		begin	
			insert Cpaym_Discount(pymntnum,nid,value)
			select *,isnull((Select top 1 nid from Cashier_Discount where [description] like '%Cur%' and [description] like '%senior%'),1),@tax1 
			from @table
		end
		if(@tax2 > 0)
		begin	
			insert Cpaym_Discount(pymntnum,nid,value)
			select *,isnull((Select top 1 nid from Cashier_Discount where [description] like '%Arr%' and [description] like '%senior%'),1),@tax2
			from @table
		end
		if(@earlybird > 0)
		begin	
			insert Cpaym_Discount(pymntnum,nid,value)
			select *,isnull((Select top 1 nid from Cashier_Discount where [description] like '%Cur%' and [description] like '%early%'),1),@earlybird
			from @table
		end

		update b
		set billstat = 3
		from cust a
		inner join cbill b
		on a.CustId = b.CustId
		and a.BillNum = b.BillNum
		and b.BillStat <> 1
		and a.CustNum = @custnum
		where a.CustId = b.CustId
		and a.BillNum = b.BillNum
		and b.BillStat <> 1
		and a.CustNum = @custnum

		update PN1
		set end_bal = end_bal - (@pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8)
		where CustId = @CustId
		and end_bal > 0
		and (@pn1 + @pn2 + @pn3 + @pn4 + @pn5 + @pn6 + @pn7 + @pn8) > 0
		set @result = 'Saved'
	 end
	select @result as result
END
