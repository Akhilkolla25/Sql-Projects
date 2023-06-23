select *
From [sql project]..BankingData

--Creating AgeGroup For Better Visualizations

Alter table BankingData
Add AgeGroup nvarchar(255);

Update [sql project]..BankingData
	
Set AgeGroup = Case	When Age < 20 then  '0-19'
				When Age < 40  then '20-39'
				When Age < 60  then  '40-59'
				Else '60-100'
				End

--Replacing 1 and 0 to Yes And No

ALTER TABLE BankingData
ALTER COLUMN Complain nvarchar(255);
--ALTER COLUMN IsActiveMember nvarchar(255);
--ALTER COLUMN HasCrCard nvarchar(255);
--ALTER COLUMN Exited nvarchar(255);



Update BankingData
Set
HasCrCard = REPLACE (HasCrCard,'1','Yes'),
IsActiveMember = REPLACE (IsActiveMember,'1','Yes'),
Exited = REPLACE (Exited,'1','Yes'),
Complain = REPLACE (Complain,'1','Yes')

Update BankingData
Set
HasCrCard = REPLACE (HasCrCard,'0','No'),
IsActiveMember = REPLACE (IsActiveMember,'0','No'),
Exited = REPLACE (Exited,'0','No'),
Complain = REPLACE (Complain,'0','No')
