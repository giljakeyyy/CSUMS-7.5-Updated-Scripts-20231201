CREATE NONCLUSTERED INDEX ix_PN1_II
ON [dbo].[PN1] ([cpnno])
INCLUDE ([end_bal],[end_watfee],[end_waterm],[end_penfee],[end_servdep],[end_procfee],[end_insfee],[end_techfee])
