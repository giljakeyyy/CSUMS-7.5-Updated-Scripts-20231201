ALTER PROCEDURE [dbo].[sp_CSSPaymentDel]
	-- Add the parameters for the stored procedure here
	@PymntNum numeric(18),
	@xuser varchar(100)
AS
BEGIN
	Declare @ORnum varchar(10);
	Declare @Paydate varchar(10);
	Declare @custnum varchar(20);

	set @ORnum = ( Select ornum from Cpaym2 where PymntNum=@PymntNum)
	set @Paydate = ( Select Convert(varchar(11),Paydate,111) from Cpaym2 where PymntNum=@PymntNum)
	set @custnum = ( Select custnum from Cpaym2 where PymntNum=@PymntNum)

	insert into Cpaym2_Logs (PymntNum,custnum,cname,PymntMode2,PymntTyp,PymntStat,PayAmnt,Subtot1,Subtot2,PayDate,PymntDtl,
	ORNum,RcvdBy,PymntMode,DtDate,xuser)
	Select PymntNum,custnum,cname,PymntMode2,PymntTyp,PymntStat,PayAmnt,Subtot1,Subtot2,PayDate,PymntDtl,
	ORNum,RcvdBy,PymntMode,getdate(),@xuser from Cpaym2 where pymntnum=@PymntNum
	
	--delete from Cpaym2 where pymntnum=@PymntNum	
	
	insert cpaym2_cancelled
	(
		CustNum ,paydate,paytype ,ornum ,oldorno 
		,payamnt ,rcvdby ,pymntmode ,deleted_by 
		,remark
	)
	Select CustNum,paydate,'Job Order',ornum,'',payamnt,rcvdby,pymntmode,@xuser,'' 
	from cpaym2
	where pymntnum = @pymntnum

	delete from cpaym2 where pymntnum = @pymntnum

	update Application_OtherFees set ornum='',Paydate='' 
	where rtrim(ltrim(Ornum))=@ORnum 
	--and Convert(varchar(20),Paydate,111)=@Paydate
	and Applnum = @custnum
END
