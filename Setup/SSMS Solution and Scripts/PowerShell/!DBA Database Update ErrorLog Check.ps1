﻿$CentralDBAServer = 'HMDBS02'
$DBADatabase = 'DBADatabase'
Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $DBADatabase -Query "TRUNCATE TABLE [INFO].[LogFileErrorMessages]" -ErrorAction Stop
$Regex = 'ERROR:|WARNING:'
$Results = Get-ChildItem 'K:\SQLBACKUP\LogFile\DBADatabase*' |Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-1)}|Select-String -Pattern $Regex|select FileName,LineNumber,Line
if (!$Results){break}
foreach($Result in $Results)
{
$FileName = $Result.FileName
$LineNumber = $Result.LineNumber
$ErrorMsg = $Result.Line 
$Matches = $result.Line.Split(' ')[2]
$Query = @"
USE [DBADatabase]
GO

INSERT INTO [Info].[LogFileErrorMessages]
           ([FileName]
           ,[ErrorMsg]
           ,[Line]
           ,[Matches])
     VALUES
           ('$FileName'
           ,'$ErrorMsg'
           ,$LineNumber
           ,'$Matches')
GO

"@
$Query
Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $DBADatabase -Query $Query

}

