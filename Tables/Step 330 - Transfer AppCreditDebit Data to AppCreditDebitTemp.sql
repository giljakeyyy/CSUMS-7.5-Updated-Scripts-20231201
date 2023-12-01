--Declare Temporary Table
Create Table AppCreditDebitTemp
(
	[CustId] int NOT NULL,
	[ApplNum] [varchar](100) NULL,
	[AdjType] [int] NULL,
	[JOAmount] [money] NULL,
	[ActualAmount] [money] NULL,
	[TotalPaid] [money] NULL,
	[Amount] [money] NULL,
	[TransDate] [datetime] NULL,
	[Username] [varchar](100) NULL
);

--Select INsert to Temp Table
Insert AppCreditDebitTemp
Select b.[CustId],a.[ApplNum],a.[Adj_Type],a.[JO_Amount],
	a.[Actual_Amount],a.[TotalPaid] ,a.[Amount] ,a.[Trans_Date],
	a.[Username]
FROM app_creditdebit a
Inner Join Cust b
on a.CustNum = b.CustNum