--Declare Temporary Table
Create Table RateGroupsTemp
(
	[RGroupid] INT NOT NULL,
	[RGDesc] [varchar](50) NULL
);

--Select INsert to Temp Table
Insert RateGroupsTemp
Select [RGroupid],[RGDesc]
FROM RateGroup;

--Create New Table
CREATE TABLE [dbo].[classificationGroups]
(
	[classificationGroupID] int identity(1,1),
	[classificationGroup] [varchar](5) NOT NULL
	 CONSTRAINT [PK_Rates] PRIMARY KEY NONCLUSTERED 
	(
		[classificationGroupID] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];