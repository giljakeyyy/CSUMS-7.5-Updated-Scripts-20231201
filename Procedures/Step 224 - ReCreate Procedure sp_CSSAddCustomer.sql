ALTER PROCEDURE [dbo].[sp_CSSAddCustomer]
	-- Add the parameters for the stored procedure here
		@CustId int,
		@Custnum varchar(20),
		@Custname varchar(100),
		@BilstAdd varchar(200),
		@Bilctadd varchar(64),
		@brgy varchar(200),
		@Billtel varchar(30),
		@ccelnumber varchar(12),
		@cemailaddr varchar(30),
		@ZoneId int,
		@RateId int,
		@cstatus varchar(1),
		@type_application varchar(1),
		@zip_code varchar(8),
		@Birthday varchar(20),
		@Age varchar(6),
		@sex varchar(6),
		@Civil_Status varchar(20),
		@BuyerClassID int,
		@remarks varchar(50),
		@dappldate varchar(20),
		@SeniorDate varchar(20),
		@SeniorID varchar(20),
		@Nature_bus varchar(30),
		@Authorized_rep varchar(30),
		@Sec_reg_no varchar(15),
		@Fax_no varchar(15),
		@designation varchar(15),
		@Applnum varchar(25),
		@bankref varchar(10),
		@oldcustnum	varchar(20),
		@temp int,
		@BookId int,
		@Seqno numeric(18),
		@PrevReading numeric(18),
		@UserName varchar(50),
		@ctc varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @BillNum numeric;
	
	if(@Birthday = '')
	BEGIN
		set @Birthday = NULL
	END
	if(@dappldate = '')
	BEGIN
		set @dappldate = NULL
	END
	IF(@SeniorDate = '')
	BEGIN
		set @SeniorDate = NULL
	END

	if(@temp=0 and not exists(Select CustId from Cust where CustNum = @Custnum))
	begin
			set @BillNum = (Select isnull(MAX(Billnum),0) +1 as Billnum from Members)

			declare @atmref varchar(10)
			set @atmref = isnull((Select isnull(cbank_ref,'') from application where applnum = @applnum),'')

			if(@atmref = '')
			begin
				set @atmref = (Select [dbo].[fnGenerateATMRef]())
			end

			declare @table table (CustId int primary key)
			Insert into cust 
			(
				Applnum,Custnum,Custname,BilstAdd,Bilctadd,SvcStadd,Svcctadd,Billtel,ccelnumber,cemailaddr,
				ZoneId,RateId,[status],type_application,zip_code,Birthday,Age,sex,Civil_Status,buyerclassID,remarks,
				dappldate,SeniorDate,SeniorID,Nature_bus,Authorized_rep,Sec_reg_no,Fox_no,designation,oldcustnum,UserName,Dttransaction,ctc,brgyid
				,cbank_ref
			)
			OUTPUT Inserted.CustId into @table(CustId)
			values
			(
				@Applnum,@Custnum,@Custname,@BilstAdd,@Bilctadd,@BilstAdd,@Bilctadd,@Billtel,@ccelnumber,@cemailaddr,
				@ZOneId,@RateId,@cstatus,@type_application,@zip_code,@Birthday,@Age,@sex,@Civil_Status,@BuyerClassID,@remarks,
				@dappldate,@SeniorDate,@SeniorID,@Nature_bus,@Authorized_rep,@Sec_reg_no,@Fax_no,@designation,@oldcustnum,@UserName,GETDATE(),@ctc,@Brgy
				,@atmref
			)

			update cust set cbank_ref=@bankref
			FROM @table CustTemp
			INNER JOIN Cust 
			on Cust.CustId = CustTemp.CustId

			update a set a.singlepoint1=b.singlepoint1,a.singlepoint2=b.singlepoint2 
			FROM @table CustTemp
			INNER JOIN Cust a
			on a.CustId = CustTemp.CustId
			inner join application b on a.Applnum=b.ApplNum

			Insert into Members 
			(
				Meterno1,BookId,CustId,Seqno,pread1,Mtype1,Billnum
			)
			values 
			(
				(select MeterNo from Application_Meters where ApplNum=@Applnum), @BookId 
				,(Select CustId from @table),@Seqno,@PrevReading,'1',@BillNum
			)
			
			Insert into cmeters 
			(
				MeterNo,CustId,Stat,Meter12,MType,MBrand,MMult,IDate,IRead,LastCons,Cstat,UserName,Dttransaction
			)
			Select MeterNo,(Select CustId from @table),'I','1',MType,MBrand,MMult,IDate,IRead,NULL,NULL,@UserName,GETDATE() from Application_Meters
			where ApplNum=@Applnum

			insert cust_ledger
			(
				CustId,posting_date,refnum,ledger_type,ledger_subtype,transaction_type,debit,remark,username
			)
			Select distinct (Select CustId from @table),getdate(),@applnum,ledger_type,'Beg',4,0,'Beginning Balance',@username 
			from cust_Ledger
			where ledger_type not in( 'STATUS')

	end	
	else if(@temp=1)
	begin
			update cust 
			SET Custname=@Custname,BilstAdd=@BilstAdd,Bilctadd=@Bilctadd,SvcStadd=@BilstAdd,Svcctadd=@Bilctadd,
			Billtel=@Billtel,ccelnumber=@ccelnumber,cemailaddr=@cemailaddr,
			ZoneId=@ZoneId,RateId=@RateId,type_application=@type_application,
			zip_code=@zip_code,Birthday=@Birthday,Age=@Age,sex=@sex,Civil_Status=@Civil_Status,buyerclassID=@BuyerClassID,remarks=@remarks,
			dappldate=@dappldate,SeniorDate=@SeniorDate,SeniorID=@SeniorID,
			Nature_bus=@Nature_bus,Authorized_rep=@Authorized_rep,Sec_reg_no=@Sec_reg_no,
			Fox_no=@Fax_no,designation=@designation,oldcustnum=@oldcustnum
			,ctc=@ctc
			,brgyid=@Brgy
			WHERE CustId=@CustId

			update Members set BookId= @BookId,Seqno=@Seqno,pread1=@PrevReading 
			where CustId=@CustId		
	end
END
