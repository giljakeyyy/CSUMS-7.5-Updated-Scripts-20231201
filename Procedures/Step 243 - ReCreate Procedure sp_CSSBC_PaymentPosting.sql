ALTER PROCEDURE [dbo].[sp_CSSBC_PaymentPosting]
	-- Add the parameters for the stored procedure here	
	@pymntNum numeric(18,0),
	@Ctrid numeric(18),
	@user varchar(50)
AS
BEGIN

	SET NOCOUNT ON;

	--Declare Variables
	Declare @CustId int
	Declare @paydate datetime		
	Declare @subtot1 money
	Declare @subtot2 money
	Declare @subtot3 money
	Declare @subtot4 money
	Declare @subtot5 money
	Declare @subtot6 money
	Declare @subtot7 money
	Declare @subtot8 money
	Declare @subtot9 money
	Declare @subtot10 money
	Declare @subtot11 money
	Declare @subtot12 money
	Declare @subtot13 money
	Declare @subtot14 money
	Declare @MeterCharge money
	Declare @WaterArrears money
	Declare @OldArrearsPN money
	Declare @septage money
	Declare @discount money
	Declare @balance money
	Declare @Balance1 money
	Declare @lcabal money
	Declare @oldarrears money
	Declare @GDBal money		
	Declare @BalServ money
	declare @pymntdtl varchar(100)
	declare @ornum varchar(100)
	declare @oldorno varchar(100)

	--Set Values to Variables
	set @CustId = 0;
	set @paydate = '';
	set @pymntdtl = '';
	set @ornum = '';
	set @oldorno = '';

	set @paydate = '';

	set @subtot1 = 0;
	set @subtot2 = 0;
	set @subtot3 = 0;
	set @subtot4 = 0;
	set @subtot5 = 0;
	set @subtot6 = 0;
	set @subtot7 = 0;
	set @subtot8 = 0;
	set @subtot9= 0;
	set @subtot10= 0;
	set @subtot11= 0;
	set @subtot12= 0;
	set @subtot13= 0;
	set @subtot14= 0;
	set @MeterCharge= 0;
	set @WaterArrears= 0;
	set @OldArrearsPN = 0;
	set @balance = 0;
	set @Balance1= 0;
	set @oldarrears= 0;
	set @GDBal= 0;		
	set @BalServ= 0;
	set @septage = 0;
	set @discount = 0;

	Select
	@MeterCharge=isnull(rwaterm,0),
	@WaterArrears=isnull(rwatfee,0),
	@OldArrearsPN = isnull(rprocfee,0),			    
	@subtot1=isnull(a.subtot1,0),
	@subtot2=isnull(a.subtot2,0),
	@subtot3=isnull(a.subtot3,0),
	@subtot4=isnull(a.subtot4,0),
	@subtot5=isnull(a.subtot5,0),
	@subtot6=isnull(a.subtot6,0),
	@subtot7=isnull(a.subtot7,0),
	@subtot8=isnull(a.subtot8,0),
	@subtot9=isnull(a.subtot9,0),
	@subtot10=isnull(a.subtot10,0),
	@subtot11=isnull(subtot11,0),
	@subtot12=isnull(subtot12,0),
	@subtot13=isnull(subtot13,0),
	@subtot14=isnull(subtot14,0),
	@paydate=a.PayDate,
	@balance=isnull(e.[Water Balance],0),
	@Balance1 = isnull(e.[Penalty Balance],0),
	@lcaBal = isnull(e.[LCA],0),
	@oldarrears= isnull(e.[Old Arrears],0),
	@GDBal =isnull(e.[Guarantee Deposit],0),				
	@BalServ = isnull(e.[SERVICE CHARGE],0),
	@septage = isnull(e.[Sewerage],0),
	@CustId=a.CustId,
	@discount = isnull(d.discount,0)

	from Cpaym a 				
	INNER JOIN Cust c 
	on a.CustId=c.CustId
	LEFT JOIN 
	(
		select pymntnum,sum(value) discount from cpaym_discount where rpymntnum is null group by pymntnum
	) d on a.PymntNum=d.pymntnum
	LEFT JOIN
	(
		select rpymntnum,sum(value) discount from cpaym_discount where rpymntnum is not null and pymntnum = 0 group by rpymntnum
	) f on a.rPymntNum=f.rpymntnum
	LEFT JOIN vw_ledger e 
	on a.CustId = e.CustId
	where a.pymntstat='1' and a.PymntNum=@pymntNum

	IF (@CustId>0)
	BEGIN
		update cust set
		LastPayDate = convert(varchar(10), @paydate, 111), [Status] = (case when isnull(@Subtot4,0) > 0 then '1' else [Status] end) 
		,DiscStatus = (case when @subtot4 > 0 then null else [DiscStatus] end)
		where CustId=@CustId	 
	END

	--Water Bill
	IF (@subtot1>0)
	BEGIN
		Insert Into Cust_Ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'WATER','CURRENT',2,@subtot1,@ornum,@user)				
	END

	--ArrearsPay
	IF (@subtot2>0)
	BEGIN
		insert into Cust_Ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'WATER','Arrears Payment',2,@subtot2,@ornum,@user)
	END

	--Advance Payment
	IF (@subtot3>0)
	BEGIN	
		insert into cust_ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'WATER','Advance Payment',2,@subtot3,@ornum,@user)
	END

	--Discount
	IF(@subtot10 > 0 or @discount > 0)
	BEGIN
		insert into cust_ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		SELECT
		a.CustId, getdate(), paydate, a.pymntnum, 'WATER', isnull(isnull(h.[description], g.[description]), 'Other Discount'), 3, isnull(f.[value], d.[value]), @ornum, @user
		FROM
		Cpaym a
		LEFT JOIN
		(
			select nid, pymntnum, [value] from cpaym_discount where rpymntnum is null
		) d on a.PymntNum=d.pymntnum
		LEFT JOIN
		(
			select nid, rpymntnum, [value] from cpaym_discount where rpymntnum is not null and pymntnum = 0
		) f on a.rPymntNum=f.rpymntnum
		LEFT JOIN Cashier_Discount g on g.nid = d.nid
		LEFT JOIN Cashier_Discount h on h.nid = f.nid
		WHERE
		a.PymntStat = '1'
		and a.pymntnum = @pymntNum
	END

	--Reconnection
	IF (@subtot4>0)
	BEGIN

		Insert Into Cust_Ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'RECONNECTION FEE','Reconnection Fee',2,@subtot4,@ornum,@user)

	END

	--Guarantee Deposit Balance/LieuShare/LCA/PCA
	IF (@subtot5>0)
	BEGIN	

		insert into cust_ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,debit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'Guarantee Deposit','Guarantee Deposit',2,@subtot5,@ornum,@user)
			
	END

	--Penlaty / Surcharge
	IF (@subtot6>0)
	BEGIN	
		insert into cust_ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'PENALTY','Penalty Fee',2,@subtot6,@ornum,@user)	
	END

	--Disconnection 
	IF(@subtot7>0)
	BEGIN
	
		Insert Into Cust_Ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'MRMF','Meter Charge',2,@subtot7,@ornum,@user)
			
	END

	--Old Arrears
	IF(@subtot9>0)
	BEGIN

		Insert Into Cust_Ledger(CustId ,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'OLD ARREARS','Old Arrears',2,@subtot9,@oldorno,@user)

	END

	--PN Penalty
	IF(@subtot11>0)
	BEGIN													
		Insert into CLedger (CustNum,Type,SubType,Pdate,Amount,Balance,Refnum,Remark)
		values ((Select custnum from Cust where CustId = @CustId),'2','12',CONVERT(varchar(11),GETDATE(),111),@subtot11,@balance,@pymntNum,'PN Penalty')		
	END


	--PN-WATER ARREARS
	IF (@WaterArrears>0)
	BEGIN

		Insert Into Cust_Ledger(CustId,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'WATER','PN-WATER ARREARS',2,@waterarrears,@ornum,@user)

	END

	--PN-OLD ARREARS
	IF (@OldArrearsPN>0)
	BEGIN	

		Insert Into Cust_Ledger(CustId,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'OLD ARREARS','PN-OLD ARREARS',2,@OldArrearsPN,@ornum,@user)

	END

	----Septage
	IF (@subtot12>0)
	BEGIN

		Insert Into Cust_Ledger(CustId,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'SEWERAGE','Sewerage Current',2,@subtot12,@ornum,@user)
		
	END

	----Septage
	IF(@subtot13>0)
	BEGIN

		Insert Into Cust_Ledger(CustId,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'SEWERAGE','Sewerage Arrears',2,@subtot13,@ornum,@user)
			
	END

	--Septage
	IF(@subtot14>0)
	BEGIN

		Insert Into Cust_Ledger(CustId,posting_date ,trans_date ,
		refnum ,ledger_type ,ledger_subtype ,
		transaction_type ,credit  ,remark ,username )
		values(@CustId,getdate(),@paydate,@pymntnum,'SEWERAGE','Sewerage Advance',2,@subtot14,@ornum,@user)
			
	END

	update Cpaym set PymntStat='5' 
	WHERE PymntNum=@pymntNum and pymntstat='1'

	update Logs_PaymentPost set pymntnum1=@pymntNum where ctrid=@Ctrid
END
