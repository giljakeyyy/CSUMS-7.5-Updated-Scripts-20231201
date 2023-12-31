ALTER PROCEDURE [dbo].[sp_cumputeunsubmittedpenalty]
	-- Add the parameters for the stored procedure here
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		declare @billdate varchar(7)
		declare @currpen money
		declare @totalpay money

		set @totalpay = 0 --fo

		set @billdate = (select max(billdate) from rhist where CustId = @CustId)
		Select @currpen = cast([bbasic] *(0.02) as numeric(18,2)) 
		FROM
		(
			Select a.CustId,b.CustNum,
			[bbasic] =
			case 
			when isnull(balance,0)<=0 
				then convert(numeric(18,2),isnull(a.subtot1,0) - isnull(a.subtot2,0))
			when isnull(balance,0)<isnull(a.subtot1,0) - isnull(a.subtot2,0)
				then convert(numeric(18,2),isnull(balance,0)) 
			else convert(numeric(18,2),isnull(a.subtot1,0) - isnull(a.subtot2,0)) end	 	
			from CBILL a 
			INNER JOIN Cust b
			on a.CustId = b.CustId	
			LEFT JOIN
			(
				Select CustId,isnull(vw_ledger.[Water Balance],0) as balance
				from vw_ledger 
				where CustId = @CustId
			) c 
			on a.CustId =c.CustId
			LEFT JOIN
			(
				Select CustId,snamount= case when isnull(a.cons1,0)<=10 then  b.minbill
				when isnull(a.cons1,0)>10 and isnull(a.cons1,0)<=20  then  b.minbill + ((a.cons1-10)*rate1) 
				when isnull(a.cons1,0)>20 and isnull(a.cons1,0)<=30  then  b.minbill + (rate1*10) + ((a.cons1-20)*rate2) end
				FROM 
				(
					Select Cust.ZoneId,Rhist.CustId,Rhist.cons1,Rhist.RateId 
					FROM Rhist 
					INNER JOIN Cust
					on Rhist.CustId = Cust.CustId
					and Cust.SeniorDate>=convert(varchar(11),getdate(),111)
					and Rhist.billdate=@billdate
					WHERE Rhist.CustId = @CustId
				) a 
				LEFT JOIN Bill b 
				on a.ZoneId = b.ZoneId And a.RateId = b.RateId
				where a.RateId=b.RateId
			) ee
			on a.CustId=ee.CustId
			WHERE a.CustId = @CustId and balance>0 and
			(
				a.billdate=@billdate 
				and a.duedate< Convert(varchar(11),getdate(),111)
			) 		
			or 
			(
				a.billdate=@billdate  
				and (b.LastPayDate>a.duedate and balance>0)  
				and a.duedate<Convert(varchar(11),getdate(),111)
			)
			or 
			(
				balance>0 and a.billdate=@billdate 
				and a.duedate<Convert(varchar(11),getdate(),111)
			)				
		) a
		LEFT JOIN CBillOthers c
		on a.CustId = c.CustId
		and c.BillDate = @billdate
		LEFT JOIN PN1 d
		on a.CustId = d.CustId
		and d.end_Watfee > 0
		LEFT JOIN dd_penaltyexemption e
		on a.CustNum = e.CustNum
		and e.billdate = @billdate
		and e.[type] <> '1'
		LEFT JOIN dd_penaltyexemption f
		on a.CustNum = f.CustNum
		and f.[type] <> '1'
  		WHERE c.BillNum is null
		and d.cpnno is null
		and e.CustNum is null
		and f.CustNum is null


		Select isnull(@currpen,0) as [PenaltyAmount]

END
