ALTER PROCEDURE [dbo].[sp_rollback_penalty]
	-- Add the parameters for the stored procedure here
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	declare @levelcounts int
	declare @ctr int
	declare @whatlevel int
	declare @percentage money
	declare @days_after int
	declare @billdate varchar(100)
	declare @duedate varchar(100)
	declare @subtot1 varchar(100)
	declare @balance money
	set @balance = (Select isnull([Water Balance],0) from vw_ledger where CustId = @CustId)
	declare @temptable as table(id int identity(1,1), penalty_level int,Percentage money,days_after int)

	set @billdate = isnull((Select billdate from cust inner join cbill on cust.CustId = cbill.CustId and cust.billnum = cbill.billnum where cust.CustId = @CustId and cbill.CustId = @CustId),'')
	set @subtot1 = isnull((Select subtot1 from cust inner join cbill on cust.CustId = cbill.CustId and cust.billnum = cbill.billnum where cust.CustId = @CustId and cbill.CustId = @CustId),0.00)
	set @duedate = (Select cbill.duedate from cust inner join cbill on cust.CustId = cbill.CustId and cust.billnum = cbill.billnum where cust.CustId = @CustId and cbill.CustId = @CustId)

	insert @temptable
	Select * from multipenalty
	order by penalty_level

	set @ctr = 1
	set @levelcounts = isnull((Select count(*) from multipenalty),0)

	WHILE(@ctr <= @levelcounts)
	BEGIN
		set @whatlevel = (Select penalty_level from @temptable where id = @ctr)
		set @percentage = (Select percentage from @temptable where id = @ctr)
		set @days_after = (Select days_after from @temptable where id = @ctr)
		IF
		(
			EXISTS
			(
				Select PenaltySubmissionId from penalty_submission where CustId = @CustId and billdate = @billdate and PenaltyLevel = @whatlevel
			) 
			and @duedate is not null
			and convert(varchar(100), dateadd(day,@days_after,convert(datetime,@duedate)),111) <= convert(varchar(100),getdate(),111)
		)
		BEGIN
			set @balance = isnull((
			Select sum(isnull(debit,0) - isnull(credit,0)) from cust_ledger
			where CustId = CustId
			and ledger_type = 'Water'
			and (convert(varchar(100),trans_date,111) < convert(varchar(100), dateadd(day,@days_after,convert(datetime,@duedate)),111) or trans_date is null)
			),0)
			IF(@balance <= 0)
			BEGIN
			
				IF(exists(Select * from cbillothers where CustId = @CustId and billdate = @billdate))
				BEGIN
					update c
					set amount1 = amount1 - (((case when @subtot1 <= @balance then @subtot1
					else @balance
					end) - ((case when @subtot1 <= @balance then @subtot1
					else @balance
					end) * (case when a.SeniorDate is not null and a.seniordate >= getdate()
					and isnull(b.Cons1,0) <= 30 then 0.05
					else 0 end))) * @percentage)
					from cust a
					inner join rhist b
					on a.CustId = b.CustId
					and b.BillDate = @billdate
					inner join cbillothers c
					on a.CustId = c.CustId
					and c.BillDate = @billdate
					where a.CustId = @CustId
				END

				insert cust_ledger
				(
					CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type
					,credit,remark,username
				)
				Select a.CustId,getdate(),getdate(),(Select billnum from cbill where CustId = @CustId and billdate = @billdate)
				,'Penalty',@billdate,12,
				a.amount as credit
				,'Surcharge for ' + @billdate,'Auto RollBack Penalty'
				from penalty_submission a
				where billdate = @billdate and CustId = @CustId
				and PenaltyLevel = @whatlevel
				

				delete a
				from penalty_submission a
				where billdate = @billdate and CustId = @CustId
				and PenaltyLevel = @whatlevel
				

			END
		END

		set @ctr = @ctr + 1
	end
END
