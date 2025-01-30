--Create New Table
CREATE TABLE [dbo].[claSSifications]
(
	[classID] int identity(1,1),
	[classificationCode] [varchar](5) NOT NULL,
	[claSSification] [varchar](50) NULL,
	[code] [varchar](5) NULL,
	[classificationGroupID] [int] NULL,
	 CONSTRAINT [PK_Rates] PRIMARY KEY NONCLUSTERED 
	(
		[classID] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	,
	FOREIGN KEY ([classificationGroupID]) REFERENCES classificationGroups([classificationGroupID]),
)
ON [PRIMARY]
