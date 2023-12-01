CREATE FULLTEXT INDEX ON [dbo].[vw_Cust](
[Account Name] LANGUAGE [English], 
[ATM Bankref] LANGUAGE [English], 
[Bill St. Address] LANGUAGE [English], 
[Customer No.] LANGUAGE [English], 
[Meter No.] LANGUAGE [English], 
[Old Customer #] LANGUAGE [English],
[TCT No.] LANGUAGE [English])
KEY INDEX [IX_vw_Cust]ON ([FullTextCatalog], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO