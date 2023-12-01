CREATE NONCLUSTERED INDEX ix_Cpaym_Discount_I
ON [dbo].[Cpaym_Discount] ([nid])
INCLUDE ([Pymntnum],[value],[rpymntnum])