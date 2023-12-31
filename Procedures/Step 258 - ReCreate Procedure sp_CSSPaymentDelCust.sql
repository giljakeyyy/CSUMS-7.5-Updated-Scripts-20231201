ALTER PROCEDURE [dbo].[sp_CSSPaymentDelCust]
	@PymntNum numeric(18),
	@xuser varchar(100),
	@Remarks varchar(100),
	@type varchar(14)
AS
BEGIN
	insert into cpaym_Logs 
	(
		PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
		Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,DtDate,xuser,remarks
	)
	Select PymntNum,Cust.CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
	Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,getdate(),@xuser,@Remarks 
	from Cpaym 
	INNER JOIN Cust
	on Cpaym.CustId = Cust.CustId
	WHERE pymntnum=@PymntNum	

	IF (len(@type)=0)
	BEGIN	

		update b
		set b.end_bal = b.end_bal + a.pn_amount,
		end_insfee = end_insfee + a.rinsfee,
		end_penfee = end_penfee + a.rpenfee,
		end_techfee = end_techfee + a.rtechfee,
		end_watfee = end_watfee + a.rwatfee,
		end_procfee = end_procfee + a.rprocfee,
		end_waterm = end_waterm + a.rwaterm,
		end_recfee = end_penfee + a.rrecfee,
		end_servdep = end_servdep + a.rservdep
		from Cpaym a 
		INNER JOIN
		pn1 b on a.pnno=b.cpnno
		WHERE PymntNum=@pymntnum
		
		insert cpaym_cancelled
		(
			CustId ,paydate,paytype ,ornum ,oldorno 
			,payamnt ,rcvdby ,pymntmode ,deleted_by 
			,remark
		)
		Select CustId,paydate,'Water',ornum,oldorno,payamnt,rcvdby,pymntmode,@xuser,@remarks 
		FROM Cpaym 
		WHERE pymntnum = @pymntnum

		DELETE a
		from pn2 a
		inner join cpaym b
		on a.cpnno = b.pnno
		and b.pymntnum = @pymntnum
		and a.crefno = CONVERT(VARCHAR, @pymntnum)


		insert Cust_Ledger
		(
			CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type,debit
			,credit,remark,username
		)
		Select CustId,getdate(),GETDATE(),refnum,ledger_type,'ADJ',12,credit
		,null,'Payment Rollback - ' + @remarks,@xuser
		from cust_ledger
		where transaction_type in ('2','3')
		and refnum = convert(varchar(100),@PymntNum)

		declare @paydate varchar(20)
		declare @paydate1 varchar(20)
		set @paydate = isnull((Select convert(varchar(20),paydate,111) from cpaym where PymntNum = @PymntNum),'')

		set @paydate1 = isnull((Select dbo.correct_paydate(@paydate) as paydate),'')

		if(@paydate = @paydate1)
		begin
			delete from cpaym where pymntnum = @pymntnum

		end

		update cpaym
		set isLateCancelled = 1
		where pymntnum = @pymntnum
	
	END
END
