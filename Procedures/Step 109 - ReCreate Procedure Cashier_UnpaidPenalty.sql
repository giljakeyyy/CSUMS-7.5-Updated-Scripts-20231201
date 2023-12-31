ALTER PROCEDURE [dbo].[Cashier_UnpaidPenalty]
	
	@CustId int,
	@mode varchar(1),
	@pymntnum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--if(@mode = 0)
	begin
		declare @billdate varchar(7)
		declare @currpen money
		declare @totalpay money

		set @totalpay = (select isnull(subtot6,0) from cpaym a where CustId = @CustId and pymntnum = @pymntnum) --fo

		set @billdate = (select max(billdate) from rhist where CustId = @CustId)
		

		Select @currpen = cast([bbasic] *(0.02) as numeric(18,2)) 
		from
		(
		Select a.CustId,
			[bbasic] = --lubao: basic charge or balance only ang basis
			case 
			when isnull(balance,0)<=0 
				then convert(numeric(18,2),isnull(a.subtot1,0) - isnull(a.subtot2,0))
			when isnull(balance,0)<isnull(a.subtot1,0) - isnull(a.subtot2,0)
				then convert(numeric(18,2),isnull(balance,0)) 
			else convert(numeric(18,2),isnull(a.subtot1,0) - isnull(a.subtot2,0)) + isnull(a.SubTot5,0) end	 	
			from CBILL a 	
			left join (Select cust.Custnum,cust.CustId,isnull(vw_ledger.[Water Balance],0) as balance,lastpaydate paydate from cust left join
			vw_ledger on cust.CustId = vw_ledger.CustId
			where cust.CustId = @CustId) c on a.CustId =c.CustId and a.BillDate >='2021/02'
			
			left join
			(Select CustId,snamount= case when isnull(a.cons1,0)<=10 then  b.minbill
			when isnull(a.cons1,0)>10 and isnull(a.cons1,0)<=20  then  b.minbill + ((a.cons1-10)*rate1) 
			when isnull(a.cons1,0)>20 and isnull(a.cons1,0)<=30  then  b.minbill + (rate1*10) + ((a.cons1-20)*rate2) end
			from (Select Cust.ZoneId,Cust.CustId,Rhist.cons1,Rhist.rateid from rhist
				INNER JOIN  Cust
				on Rhist.CustId = Cust.CustId
				and SeniorDate>=convert(varchar(11),getdate(),111)
				WHERE billdate=@billdate) a left join bill b on 
			a.ZoneId = b.ZoneId And a.RateId = b.RateId
			where  a.ZoneId=b.ZoneId and a.RateId=b.RateId) ee
			on a.CustId=ee.CustId
			where a.CustId = @CustId and balance>0 and
				(a.billdate=@billdate 
					and duedate< Convert(varchar(11),getdate(),111)) 		
					or 
					(a.billdate=@billdate  
					and (paydate>duedate and balance>0)  
					and duedate<Convert(varchar(11),getdate(),111))
					or 
					(balance>0 and a.billdate=@billdate 
					and duedate<Convert(varchar(11),getdate(),111))				
				) a
			LEFT JOIN CBillOthers b
			on a.CustId = b.CustId
			and b.BillDate=@billdate
  			 where b.CbillOthersId is null
			and a.CustId not in(select Cust.CustId from pn1 a 
			INNER JOIN CUST
			on a.CustId = Cust.CustId
			and Cust.CustId = @CustId
			left join
			(select cpnno,sum(rwatfee) rwatfee from pn2 group by cpnno) b on a.cpnno = b.cpnno
			where a.end_bal > 0 and a.nwatfee > 0
			and a.nwatfee - b.rwatfee = 0
			and Cust.CustId = @CustId)
			and a.CustId not in(select Cust.CustId from dd_penaltyexemption 
			INNER JOIN CUST
			on dd_penaltyexemption.custnum = Cust.Custnum
			and Cust.CustId = @CustId
			where billdate = @billdate and Cust.CustId = @CustId)
			and a.CustId not in(select Cust.CustId from dd_PenaltyExemption 
			INNER JOIN CUST
			on dd_penaltyexemption.custnum = Cust.Custnum
			and Cust.CustId = @CustId
			where type='1' and Cust.CustId = @CustId)

		declare @balance money
		--set @balance =  (Select balance1 from cust where custnum = @custnum)
		set @balance = (Select isnull([Penalty balance], 0) from vw_ledger where CustId = @CustId)
		declare @waterpn money
		set @waterpn =	(select npenfee from pn1 
			INNER JOIN CUST
			on pn1.CustId = Cust.CustId
			and Cust.CustId = @CustId
			where Cust.CustId = @CustId and end_bal >0)
		declare @currpay money
		set @currpay = (select sum(subtot6) from cpaym where CustId = @CustId and pymntstat=1 and left(paydate,7) = convert(varchar(7),getdate(),111))

		select CONVERT(DECIMAL(18, 2), (((@balance + isnull(@currpen,0)) - isnull(@waterpn,0)) - isnull(@currpay,0)) + isnull(@totalpay,0)) as TotalBill,
		'PENALTY CHARGE' as BillType,'' duedate,'Subtot6' Subtot,'WATER' Ptype,isnull(@totalpay,0) TotalPay
		end
	END
