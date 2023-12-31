ALTER PROCEDURE [dbo].[sp_auto_penalty]
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
	declare @cust_status varchar(2)
	declare @cust_rate int
	declare @billdate varchar(100)
	declare @duedate varchar(100)
	declare @subtot1 money
	declare @balance money
	declare @payamnt money
	set @balance = (Select isnull([Water Balance],0) from vw_ledger where CustId = @CustId)

	declare @temptable as table(id int identity(1,1), penalty_level int,Percentage money,days_after int)

	set @billdate = isnull((Select billdate from cust inner join cbill on cust.CustId = cbill.CustId and cust.billnum = cbill.billnum where cust.CustId = @CustId and cbill.CustId = @CustId),'')
	set @subtot1 = isnull((Select subtot1 from cust inner join cbill on cust.CustId = cbill.CustId and cust.billnum = cbill.billnum where cust.CustId = @CustId and cbill.CustId = @CustId),0.00)
	set @duedate = (Select cbill.duedate from cust inner join cbill on cust.CustId = cbill.CustId and cust.billnum = cbill.billnum where cust.CustId = @CustId and cbill.CustId = @CustId)

	set @cust_status = (select isnull([status],'') from cust where CustId = @CustId)
	set @cust_rate = (select isnull(RateId,0) from cust where CustId = @CustId)

	set @payamnt = isnull((Select sum(subtot1 + subtot2 + subtot3 + subtot10) from cpaym where CustId = @CustId and PymntStat = 1),0.00)
	insert @temptable
	Select * from multipenalty
	order by penalty_level

	set @ctr = 1
	set @levelcounts = isnull((Select count(*) from multipenalty),0)

		if(@cust_status = '1')
		begin
			while(@ctr <= @levelcounts)
			begin
				set @whatlevel = (Select penalty_level from @temptable where id = @ctr)
				set @percentage = (Select percentage from @temptable where id = @ctr)
				set @days_after = (Select days_after from @temptable where id = @ctr)
				if(not exists(Select CustId from penalty_submission where CustId = (Select CustId from Cust where CustId = @CustId) and billdate = @billdate and penaltylevel = @whatlevel) 
				and @duedate is not null
				and convert(varchar(100), dateadd(day,@days_after,convert(datetime,@duedate)),111) <= convert(varchar(100),getdate(),111)
				)
				begin
					set @balance = isnull((
					Select sum(isnull(debit,0) - isnull(credit,0)) from cust_ledger
					where CustId = @CustId
					and ledger_type = 'Water'
					and (convert(varchar(100),trans_date,111) < convert(varchar(100), dateadd(day,@days_after,convert(datetime,@duedate)),111) or trans_date is null)
					),0)

					set @balance = isnull(@balance,0) - isnull(@payamnt,0)

					if(@balance > 0 and (convert(varchar(100),dateadd(day,(@days_after + 4),convert(datetime,@duedate)),111) < convert(varchar(100),getdate(),111)))
					begin
						set @balance = isnull((case @subtot1 when 0 then @balance else @subtot1 end),0)
						if(not exists(Select CbillOthersId from cbillothers where CustId = (Select CustId from Cust where CustId = @CustId) and billdate = @billdate))
						begin
							insert cbillothers(billnum,CustId,billdate,amount1,amount2)
							Select (Select billnum from cbill where CustId = @CustId and billdate = @billdate)
							,a.CustId,@billdate,
							((case when @subtot1 <= @balance then @subtot1
							else @balance
							end) - ((case when @subtot1 <= @balance then @subtot1
							else @balance
							end) * (case when a.SeniorDate is not null and a.seniordate >= getdate()
							and isnull(b.Cons1,0) <= 30 then 0.05
							else 0 end))) * @percentage as debit,(Select isnull([Penalty Balance],0) from vw_ledger where CustId = @CustId)
							from cust a
							inner join rhist b
							on a.CustId = b.CustId
							and b.BillDate = @billdate
							where a.CustId = @CustId
						end
						else 
						begin
							update c
							set amount1 = amount1 + (((case when @subtot1 <= @balance then @subtot1
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
						end

						insert cust_ledger(CustId,posting_date,trans_date,refnum,ledger_type,ledger_subtype,transaction_type
						,debit,remark,username)
						Select a.CustId,getdate(),getdate(),(Select billnum from cbill where CustId = @CustId and billdate = @billdate)
						,'Penalty',@billdate,11,
						convert(numeric(18,2),(((case when @subtot1 <= @balance then @subtot1
						else @balance
						end) - ((case when @subtot1 <= @balance then @subtot1
						else @balance
						end) * (case when a.SeniorDate is not null and a.seniordate >= getdate()
						and isnull(b.Cons1,0) <= 30 then 0.05
						else 0 end))) * @percentage)) as debit
						,'Surcharge for ' + @billdate,'AutoPenalty'
						from cust a
						inner join rhist b
						on a.CustId = b.CustId
						and b.BillDate = @billdate
						where a.CustId = @CustId

						insert penalty_submission(penaltylevel,billnum,billdate,CustId,amount)
						Select @whatlevel,(Select billnum from cbill where CustId = @CustId and billdate = @billdate)
						,@billdate,a.CustId,
							((case when @subtot1 <= @balance then @subtot1
							else @balance
							end) - ((case when @subtot1 <= @balance then @subtot1
							else @balance
							end) * (case when a.SeniorDate is not null and a.seniordate >= getdate()
							and isnull(b.Cons1,0) <= 30 then 0.05
							else 0 end))) * @percentage as debit
							from cust a
							inner join rhist b
							on a.CustId = b.CustId
							and b.BillDate = @billdate
							where a.CustId = @CustId
					end
				end

				set @ctr = @ctr + 1
			end
		end
	--end
END
