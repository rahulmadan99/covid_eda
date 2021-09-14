alter table covid_deaths
	add new_date datetime;
    
UPDATE covid_deaths
	SET new_date = STR_TO_DATE(date, '%e-%c-%Y ');
    
    
-- altering type of total_deaths    
ALTER TABLE covid_deaths 
  MODIFY  new_deaths int; 
  
  
  
 -- converting all empty strings to null 
UPDATE
    covid_deaths
SET
    continent = CASE continent WHEN '' THEN NULL ELSE continent END,
    total_deaths = CASE total_deaths WHEN '' THEN NULL ELSE total_deaths END,
    new_deaths = CASE new_deaths WHEN '' THEN NULL ELSE new_deaths END;
    
    
    
-- column99 = CASE column99 WHEN '' THEN NULL ELSE column99 END
update covid_deaths set new_deaths = null where new_deaths = '';



-- covid vacc table modifications
update covid_vacc set new_vaccinations = null where new_vaccinations = '';

ALTER TABLE covid_vacc
  MODIFY  new_vaccinations int; 
