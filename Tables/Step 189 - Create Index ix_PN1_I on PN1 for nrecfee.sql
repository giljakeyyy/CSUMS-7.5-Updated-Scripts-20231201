CREATE NONCLUSTERED INDEX ix_PN1_I
ON [dbo].[PN1] ([nrecfee])
INCLUDE (CustId,[npn_amt],[beg_bal],[end_bal],[userdate],[nwaterm],[npenfee],[nservdep],[nprocfee],[ninsfee],[ntechfee],[nwatfee])
