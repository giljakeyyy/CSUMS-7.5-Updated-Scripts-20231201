ALTER FUNCTION [dbo].[checkdiscon]()
RETURNS TABLE
AS
RETURN
(
    select c.CustId,c.custnum,c.#ofArrears from
    (
        select d.CustId,d.custnum, c.[Water Balance], subtot1, subtot1 + subtot4 as [3mos], c.[Old Arrears],--,x.#ofArrears/*,
        case when c.[Water Balance] + c.[Old Arrears] <= SubTot1 then --balance>0 then 1 month arrears?
        '1'
        when isnull(c.[Water Balance],0) + isnull(c.[Old Arrears],0) > subtot1 and isnull(c.[Water Balance],0) + isnull(c.[Old Arrears],0) <= subtot1+subtot4 then --balance + old> basic = 2months
        '2'
        when isnull(c.[Water Balance],0) + isnull(c.[Old Arrears],0) > subtot1 + subtot4 then
        '3'
        end as #ofArrears
        from
        (
            select b.CustId, b.subtot1, b.subtot4 from
            (
                SELECT CustId, billdate = MAX(billdate)
                FROM cbill
                where billstat <> '1'
                group by CustId
            ) a
            left join cbill b on
            b.CustId = a.CustId and b.billdate = a.billdate
        ) b left join vw_ledger c on b.CustId = c.CustId
		left join Cust d
		on b.CustId = d.CustId
	)c
    where isnull(c.[Water Balance],0) + isnull(c.[Old Arrears],0) > 0


)