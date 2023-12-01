ALTER VIEW [dbo].[vw_ledger]

AS
Select a.CustId,a.custnum,water.balance as [Water Balance] 
,sewerage.balance as Sewerage,[Old Arrears].balance as [Old Arrears],
PENALTY.balance as [Penalty Balance],[SERVICE CHARGE].balance as [SERVICE CHARGE]
,LCA.balance as LCA,[RECONNECTION FEE].balance as [RECONNECTION FEE]

,[Guarantee Deposit].balance as [Guarantee Deposit]
,lahat.balance as [Total Balance]
from cust a
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'WATER'
group by CustId)water
on a.CustId = water.CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'SEWERAGE'
group by CustId)sewerage
on a.CustId = sewerage.CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'OLD ARREARS'
group by CustId)[Old Arrears]
on a.CustId = [Old Arrears].CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'PENALTY'
group by CustId)PENALTY
on a.CustId = PENALTY.CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'MRMF'
group by CustId)[SERVICE CHARGE]
on a.CustId = [SERVICE CHARGE].CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'LCA'
group by CustId)LCA
on a.CustId = LCA.CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'RECONNECTION FEE'
group by CustId)[RECONNECTION FEE]
on a.CustId = [RECONNECTION FEE].CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type = 'Guarantee Deposit'
group by CustId)[Guarantee Deposit]
on a.CustId = [Guarantee Deposit].CustId
left join(
Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
where ledger_type <> 'Guarantee Deposit'
group by CustId)lahat
on a.CustId = lahat.CustId
