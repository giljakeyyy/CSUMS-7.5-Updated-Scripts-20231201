ALTER PROCEDURE [dbo].[jva_collperday]
(
	-- Add the parameters for the stored procedure here
	@billdate1 varchar(7)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @billdate varchar(7)
	set @billdate = @billdate1

	begin
		select a.*,
		isnull([Current Water Bill Coll],0) [Current Water Bill Coll], 
		isnull([Current Arrears Coll],0) [Current Arrears Coll],
		isnull([Advance Payment],0) [Advance Payment], 
		isnull([Old Arrears Coll],0) [Old Arrears Coll],
		isnull([Delivery charge],0) [Delivery charge], 
		isnull(Deposit,0) Deposit, 
		isnull([Guarantee],0) [Guarantee Deposit],
		isnull(Surcharge,0) Surcharge, [MRMF]--, 
		,[Sewerage Current]
		,[Sewerage Arrears]
		,[Sewerage Advance],
		isnull([Water Delivery],0) [Water Delivery], isnull(c.Application_fee,0) as Application_fee,isnull(Application_Others,0) as Application_Others,	

		isnull([PN-Water Arrears],0) [PN-Water Arrears], 
		isnull([PN-Old Arrears],0) [PN-Old Arrears], 
		isnull([PN Meter Charge],0) [PN Meter Charge],
		isnull([PN Technical Cost],0) [PN Technical Cost],
		isnull([PN Installation Fee],0) [PN Installation Fee],
		isnull([PN Service Deposit Fee],0) [PN Service Deposit Fee],
		isnull([PN Penalty Fee],0) [PN Penalty Fee],
		isnull([PN Reconnection Fee],0) [PN Reconnection Fee],

		(
			isnull([Current Water Bill Coll],0) + isnull([Current Arrears Coll],0) + isnull([Advance Payment],0) + isnull([Old Arrears Coll],0) + isnull([Delivery charge],0) + isnull(Deposit,0) +
			isnull(Surcharge,0) + isnull([MRMF],0) + isnull([Water Delivery],0) + isnull(Application_fee,0) + isnull(Application_Others,0) +
			isnull([PN-Water Arrears],0) +
			isnull([PN-Old Arrears],0) +
			isnull([PN Meter Charge],0) +
			isnull([PN Technical Cost],0) +
			isnull([PN Installation Fee],0) +
			isnull([PN Service Deposit Fee],0) +
			isnull([PN Penalty Fee],0) +
			isnull([PN Reconnection Fee],0) +
			isnull([Sewerage Current],0) +
			isnull([Sewerage Advance],0) +
			isnull([Sewerage Arrears],0)
		) as [Total Collection]  
		from
		(
			select paydate from cpaym  where left(paydate,7)=@billdate
			union
			select paydate from cpaym2 where left(paydate,7)=@billdate
		) a
		left join
		(
			select paydate,
			sum(isnull(subtot1,0)) as [Current Water Bill Coll],
			sum(isnull(a.subtot2,0)) as [Current Arrears Coll],
			sum(isnull(subtot3,0)) as [Advance Payment],
			sum(isnull(subtot9,0)) as [Old Arrears Coll], 
			sum(isnull(subtot4,0)) as [Delivery charge],
			sum(isnull(subtot5,0)) as Deposit, 
			sum(isnull(a.Subtot3,0))  as [Guarantee Deposit],
			cast(sum(isnull(subtot6,0)) as decimal(18,2)) as Surcharge, 

			sum(isnull(subtot7,0)) as [MRMF] /* [Service Fee]*/, 
			sum(isnull(subtot8,0))  as [Water Delivery],
			sum(isnull(subtot12,0))  as [Sewerage Current],
			sum(isnull(subtot13,0))  as [Sewerage Arrears],
			sum(isnull(subtot14,0))  as [Sewerage Advance],
		
			[PN-Water Arrears]= sum(isnull(rwatfee,0)),
			[PN-Old Arrears]=sum(isnull(rprocfee,0)),
			[PN Meter Charge]=sum(isnull(rwaterm,0)),
			[PN Technical Cost]=sum(isnull(rtechfee,0)),
			[PN Installation Fee]=sum(isnull(rinsfee,0)),
			[PN Service Deposit Fee]=sum(isnull(rservdep,0)),
			[PN Penalty Fee]=sum(isnull(rpenfee,0)),
			[PN Reconnection Fee]=sum(isnull(rrecfee,0)) 
			from cpaym a
			where left(paydate,7) = @billdate group by paydate
		)
		b on a.paydate = b.paydate
		left join
		(
			select paydate, sum(isnull(subtot1,0)) as  Application_fee, sum(isnull(subtot2,0)) as Application_Others,sum(isnull(subtot3,0)) as [Guarantee] from cpaym2 where left(paydate,7)=@billdate
			group by paydate
		) c on a.paydate = c.paydate
	order by paydate
	end
END
