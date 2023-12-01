CREATE TABLE ScriptstoExecute
(
	ExecId int identity(1,1),
	ExecSequence int,
	ExecObjectType VARCHAR(50),
	ScriptPath VARCHAR(250),
	CONSTRAINT UQ_ScriptstoExecute UNIQUE(ScriptPath)
)