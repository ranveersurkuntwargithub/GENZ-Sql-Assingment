use genzdataset;

# 1) how many male have responded to the survey from india ?

SELECT 
    COUNT(ResponseID) AS total_responses
FROM
    personalized_info
WHERE
    CurrentCountry = 'India'
        AND Gender LIKE 'male%';

# 2) How many female have responded to the survey from India ?

SELECT 
    COUNT(ResponseID) AS No_of_female
FROM
    personalized_info
WHERE
    Gender LIKE 'Female%';

# 3) How many of the Gen-Z are influenced by their parents in regards to their career choices from india ?

SELECT 
    CareerInfluencefactor,
    COUNT(CareerInfluencefactor) AS total_in_india
FROM
    learning_aspirations AS la
        JOIN
    personalized_info AS pi ON la.ResponseID = pi.ResponseID
WHERE
    CurrentCountry = 'india'
        AND CareerInfluencefactor = 'My Parents';
 
 # 4) How many of the female Gen-Z are influenced by their parents in regards to their career choices from india ?
 
SELECT 
    la.CareerInfluencefactor,
    pi.gender,
    COUNT(la.CareerInfluencefactor) AS total_in_india
FROM
    learning_aspirations AS la
        JOIN
    personalized_info AS pi ON la.ResponseID = pi.ResponseID
WHERE
    CurrentCountry = 'india'
        AND CareerInfluencefactor = 'My Parents'
        AND Gender LIKE '%female%'
GROUP BY gender , CareerInfluencefactor;
 
 # 5) How many of the male Gen-Z are influenced by their parents in regards to their career choices from india ?
 
SELECT 
    la.CareerInfluencefactor,
    pi.gender,
    COUNT(la.CareerInfluencefactor) AS total_in_india
FROM
    learning_aspirations AS la
        JOIN
    personalized_info AS pi ON la.ResponseID = pi.ResponseID
WHERE
    CurrentCountry = 'india'
        AND CareerInfluencefactor = 'My Parents'
        AND Gender LIKE 'male%'
GROUP BY gender , CareerInfluencefactor;

# 6) How many of the male and female ( individually display in 2 different columns but as part of the same query ) Gen Z are influenced by their parents in regards to their
# career choice in india 
 
SELECT 
    la.CareerInfluencefactor,
    SUM(CASE
        WHEN Gender LIKE 'Male%' THEN 1
        ELSE 0
    END) AS Male_Influenced,
    SUM(CASE
        WHEN Gender LIKE 'Female%' THEN 1
        ELSE 0
    END) AS Female_Influenced
FROM
    learning_aspirations AS la
        JOIN
    personalized_info AS pi ON la.ResponseID = pi.ResponseID
WHERE
    CurrentCountry = 'india'
        AND CareerInfluencefactor = 'My Parents'
GROUP BY CareerInfluencefactor;
 
 # 7) How many Gen Z are influenced by media and influencers together from india

SELECT 
    COUNT(la.ResponseID) AS influenced_count
FROM
    learning_aspirations la
        JOIN
    personalized_info pi ON la.ResponseID = pi.ResponseID
WHERE
    pi.CurrentCountry = 'india'
        AND la.CareerInfluencefactor = 'Influencers who had successful careers'
        OR la.CareerInfluencefactor = 'Social Media like LinkedIn';

 
 # 8) How many Gen Z are influenced by media and influencers together display for male and female seperately from india
 
SELECT 
    pi.gender, COUNT(la.ResponseID) AS influenced_count
FROM
    learning_aspirations la
        JOIN
    personalized_info pi ON la.ResponseID = pi.ResponseID
WHERE
    pi.CurrentCountry = 'india'
        AND la.CareerInfluencefactor = 'Influencers who had successful careers'
        OR la.CareerInfluencefactor = 'Social Media like LinkedIn'
GROUP BY gender
ORDER BY influenced_count DESC;
 
# 9) How many of the Gen-Z who are influenced by the social media for their career aspiration are looking to go abroad 

SELECT 
    la.CareerInfluencefactor,
    la.HigherEducationAbroad,
    COUNT(la.ResponseID) AS influenced_count
FROM
    learning_aspirations la
        JOIN
    personalized_info pi ON la.ResponseID = pi.ResponseID
WHERE
    la.HigherEducationAbroad = 'Yes, I wil'
        AND la.CareerInfluencefactor = 'Social Media like LinkedIn'
GROUP BY la.CareerInfluencefactor , la.HigherEducationAbroad;
 
# 10) How many of the Gen-Z who are influenced by the people in their circle for  career aspiration are looking to go abroad 

SELECT 
    la.CareerInfluencefactor,
    la.HigherEducationAbroad,
    COUNT(la.ResponseID) AS influenced_count
FROM
    learning_aspirations la
        JOIN
    personalized_info pi ON la.ResponseID = pi.ResponseID
WHERE
    la.HigherEducationAbroad = 'Yes, I wil'
        AND la.CareerInfluencefactor = 'People from my circle, but not family members'
GROUP BY la.CareerInfluencefactor , la.HigherEducationAbroad;

#11)  What is the percentage of male and female Gen-Z wants to go to office every day ?

WITH cte AS 
	(SELECT 
	 CASE WHEN gender LIKE "male%" THEN 1 ELSE 0 END  AS male, 
	 CASE WHEN gender LIKE  "%female%"  THEN 1 ELSE 0 END AS female 
     FROM learning_aspirations la JOIN personalized_info pi ON la.ResponseID = pi.ResponseID 
     WHERE PreferredWorkingEnvironment LIKE 
	"Every Day Office Environment" ) 
SELECT round((sum(male) * 100.0/(sum(male)+sum(female))),2)  AS percentage_of_male,
	   round((sum(female)*100.0/(sum(male) + sum(female))),2) AS percentage_of_female 
FROM cte;

# 12) What percentage of Genz's who have chosen their career in Business operations are more likely to be influenced by their parents ?

WITH total_responce_id AS (
SELECT ResponseID AS counts FROM personalized_info
)
SELECT (
round(COUNT(la.ResponseID) / (SELECT COUNT(counts) FROM total_responce_id) * 100,2)
) AS percentage
FROM total_responce_id tri JOIN learning_aspirations la ON la.ResponseID = tri.counts
WHERE la.ClosestAspirationalCareer LIKE '%Business Operations%' AND la.CareerInfluenceFactor LIKE 'My Parents';

# 13) What percentage of Genz prefer opting for higher studies, give a gender wise approach ?

        
WITH total_responce_id AS 
(
SELECT pi.ResponseID as counts,
	CASE WHEN pi.gender LIKE "male%" THEN 1 ELSE 0 END AS male ,
	CASE WHEN pi.gender LIKE "%female%" THEN 1 ELSE 0 END AS female 
FROM personalized_info pi JOIN learning_aspirations la ON la.ResponseID = pi.ResponseID
WHERE la.HigherEducationAbroad LIKE 'Yes, I wil'
)
SELECT round(sum(male)/count(counts)*100,2) AS male_percentage,
	   round(sum(female)/count(counts)*100,2) AS female_percentage  
FROM total_responce_id;

# 14) What percentage of genz are willing & not willing to work for company whose mission is misalinged with their public actions or even their products ?
# ( give gender base split )

WITH cte AS ( SELECT ma.ResponseID,pi.gender,
	CASE WHEN MisalignedMissionLikelihood LIKE 'Will NOT work for them' THEN 1 ELSE 0 END AS will_not_work ,
	CASE WHEN MisalignedMissionLikelihood LIKE 'Will work for them' THEN 1 ELSE 0 END AS will_work
    from mission_aspirations ma join personalized_info pi ON ma.ResponseID = pi.ResponseID)
SELECT gender,
	   ROUND(sum(will_not_work)/count(ResponseID)*100,2) AS willNotWork_percentage,
	   ROUND(sum(will_work)/count(ResponseID)*100,2) as willWork_percentage
FROM cte  WHERE gender LIKE "male%" OR gender LIKE "female%" GROUP BY gender;

# 15) What is the most suitable working environment according to female genz's ?

SELECT 
    COUNT(ma.ResponseID) AS no_of_people, PreferredWorkSetup
FROM
    manager_aspirations ma
        JOIN
    personalized_info pi ON ma.ResponseID = pi.ResponseID
WHERE
    pi.gender LIKE 'female%'
GROUP BY PreferredWorkSetup
ORDER BY no_of_people DESC
LIMIT 1;

# 16) Calculate the total number of female who aspire to work in their closets Aspirational career and have a no social impact likelihood of "1 to 5" 

SELECT 
    COUNT(pa.ResponseID) AS total_female
FROM
    personalized_info pa
        JOIN
    mission_aspirations ma ON pa.ResponseID = ma.ResponseID
WHERE
    gender LIKE 'female%'
        AND ma.NoSocialImpactLikelihood BETWEEN 1 AND 5;

# 17) Retrieve the male who are interested in Higher Education Abroad and have a career influence factor "my parents" ?
 
SELECT 
    la.ResponseID, pi.gender, la.HigherEducationAbroad
FROM
    learning_aspirations la
        JOIN
    personalized_info pi ON la.ResponseID = pi.ResponseID
WHERE
    HigherEducationAbroad = 'Yes, I wil'
        AND CareerInfluenceFactor = 'My Parents'
        AND gender LIKE 'male%'
ORDER BY la.ResponseID;

# 18) Determine the percentage of gender who have no social impact likelihood of 8 to 10 among those who are interested in higher education abroad ?

with cte as (
select  la.ResponseID as total_counts,gender,
case when la.HigherEducationAbroad = 'Yes, I wil' and ma.NoSocialImpactLikelihood between 8 and 10 then 1 else 0 end as no_ofNo_impact
from learning_aspirations la 
join mission_aspirations ma on la.ResponseID = ma.ResponseID
join personalized_info pi on pi.ResponseID = ma.ResponseID
) 
select gender,(round( sum(no_ofNo_impact)/count(total_counts)*100,2)) as percentage 
from cte 
group by gender;


# 19) Give a detailed split of the GenZ perfomences to work with the teams, Data should include male and female and overall in counts and aslo the overall in % ?

with cte as (
select ResponseID as ids,gender from personalized_info )
select gender,count(ids) total_employees,round(count(ids)/3004*100,2) as percentage
from cte
join manager_aspirations ma on cte.ids = ma.ResponseID
where ma.PreferredWorkSetup like "%in my team%"
group by gender;

# 20) Give a detailed breakdowm of "Worklikelihood3years" for each gender ?
#counts
SELECT 
    COUNT(ma.ResponseID) AS no_of_people,
    pi.gender,
    ma.WorkLikelihood3Years
FROM
    manager_aspirations ma
        JOIN
    personalized_info pi ON ma.ResponseID = pi.ResponseID
GROUP BY ma.WorkLikelihood3Years , pi.gender
ORDER BY gender;

# 21) what is the average starting salary expectations at 3 year mark  for each gender ?

SELECT 
    pa.gender,
    CONCAT(ROUND(AVG(ma.ExpectedSalary3Years), 2),
            ' k') AS starting_average_salary_3
FROM
    mission_aspirations ma
        JOIN
    personalized_info pa ON pa.ResponseID = ma.ResponseID
GROUP BY gender
HAVING gender IS NOT NULL;

 # 22) what is the average starting salary expectations at 5 year mark  for each gender ?
 
SELECT 
    pa.gender,
    CONCAT(ROUND(AVG(ma.ExpectedSalary5Years), 2),
            ' k') AS starting_average_salary_5yr
FROM
    mission_aspirations ma
        JOIN
    personalized_info pa ON pa.ResponseID = ma.ResponseID
GROUP BY gender
HAVING gender IS NOT NULL;

# 23) what is the average higher bar salary expectations at 3 year mark  for each gender?

SELECT 
    pa.gender,
    CONCAT(ROUND(AVG(ma.ExpectedSalary3Years), 2),
            ' k') AS higher_average_salary_3
FROM
    mission_aspirations ma
        JOIN
    personalized_info pa ON pa.ResponseID = ma.ResponseID
GROUP BY gender
HAVING gender IS NOT NULL;

# 24) what is the average higher bar salary expectations at 3 year mark  for each gender?

SELECT 
    pa.gender,
    CONCAT(ROUND(AVG(ma.ExpectedSalary5Years), 2),
            ' k') AS higher_average_salary_5yr
FROM
    mission_aspirations ma
        JOIN
    personalized_info pa ON pa.ResponseID = ma.ResponseID
GROUP BY gender
HAVING gender IS NOT NULL;


