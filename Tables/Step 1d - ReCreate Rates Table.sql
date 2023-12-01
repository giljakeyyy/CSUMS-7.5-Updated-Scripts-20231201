--Create New Table
CREATE TABLE [dbo].[Rates](
	[RateId] int identity(1,1),
	[RateCd] [varchar](5) NOT NULL,
	[RateName] [varchar](50) NULL,
	[code] [varchar](5) NULL,
	[rgroupid] [int] NULL,
	 CONSTRAINT [PK_Rates] PRIMARY KEY NONCLUSTERED 
	(
		[RateId] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	
	) ON [PRIMARY]
