-- Looking at the data overall

Select *
From VehicleAccidentDesc
Order by 1, 2;

Select *
From VehicleAccidentInv
Order by 1, 2;

Select *
From VehicleAccidentDesc
Where COALESCE(DAY_OF_WEEK_CODE_Desc, DAY_OF_WEEK_Desc, CRASH_CLASSIFICATION_CODE, CRASH_CLASSIFICATION_DESCRIPTION, MANNER_OF_IMPACT_CODE, MANNER_OF_IMPACT_DESCRIPTION,
	ROAD_SURFACE_CODE, ROAD_SURFACE_DESCRIPTION, LIGHTING_CONDITION_CODE, LIGHTING_CONDITION_DESCRIPTION, WEATHER_1_CODE, WEATHER_1_DESCRIPTION, PRIMARY_CONTRIBUTING_CIRCUMSTANCE_CODE,
	PRIMARY_CONTRIBUTING_CIRCUMSTANCE_DESCRIPTION, [LATITUDE/LONGITUDE_Desc]) is NULL

-- Checking for other crash classification code errors and checking the number of crashes for each severity of the crash

Select CRASH_CLASSIFICATION_CODE, Count(CRASH_CLASSIFICATION_CODE) as NUMBER_OF_CRASHES
From VehicleAccidentDesc
Group by CRASH_CLASSIFICATION_CODE
Order by 2 Desc

-- Deleting the outlier from both tables because the crash classification code goes from 1 to 4

Delete from VehicleAccidentDesc
Where "CRASH_CLASSIFICATION_CODE" = 32

Delete from VehicleAccidentInv
Where "CRASH_DATETIME_Inv" = '07/31/2018 06:23:00 PM +0000'

-- Deleting the crash classification code errors
 
Delete from VehicleAccidentDesc
Where CRASH_CLASSIFICATION_CODE is NULL or CRASH_CLASSIFICATION_CODE in (0, 0.1, 0.3, 0.2)

-- Looking at any null values for both tables

Select *
From VehicleAccidentDesc
Where CRASH_DATETIME_Desc is NULL or DAY_OF_WEEK_CODE_Desc is NULL or DAY_OF_WEEK_Desc is NULL or CRASH_CLASSIFICATION_CODE is NULL 
	or CRASH_CLASSIFICATION_DESCRIPTION is NULL or MANNER_OF_IMPACT_CODE is NULL or MANNER_OF_IMPACT_DESCRIPTION is NULL or ROAD_SURFACE_CODE is NULL 
	or ROAD_SURFACE_DESCRIPTION is NULL or LIGHTING_CONDITION_CODE is NULL or LIGHTING_CONDITION_DESCRIPTION is NULL or WEATHER_1_CODE is NULL or WEATHER_1_DESCRIPTION is NULL 
	or PRIMARY_CONTRIBUTING_CIRCUMSTANCE_CODE is NULL or PRIMARY_CONTRIBUTING_CIRCUMSTANCE_DESCRIPTION is NULL or [LATITUDE/LONGITUDE_Desc] is NULL

Select *
From VehicleAccidentInv
Where CRASH_DATETIME_Inv is NULL or DAY_OF_WEEK_CODE_Inv is NULL or DAY_OF_WEEK_Inv is NULL or COLLISION_ON_PRIVATE_PROPERTY is NULL or PEDESTRIAN_INVOLVED is NULL
	or ALCOHOL_INVOLVED is NULL or DRUG_INVOLVED is NULL or SEATBELT_USED is NULL or MOTORCYCLE_INVOLVED is NULL or MOTORCYCLE_HELMET_USED is NULL
	or BICYCLED_INVOLVED is NULL or BICYCLE_HELMET_USED is NULL or SCHOOL_BUS_INVOLVED is NULL or LATITUDE is NULL or LONGITUDE is NULL or [LATITUDE/LONGITUDE_Inv] is NULL

-- Deleting all NULL values

Delete from VehicleAccidentInv
Where CRASH_DATETIME_Inv is NULL

Delete from VehicleAccidentDesc
Where CRASH_DATETIME_Desc is NULL or DAY_OF_WEEK_CODE_Desc is NULL or DAY_OF_WEEK_Desc is NULL or CRASH_CLASSIFICATION_CODE is NULL 
	or CRASH_CLASSIFICATION_DESCRIPTION is NULL or MANNER_OF_IMPACT_CODE is NULL or MANNER_OF_IMPACT_DESCRIPTION is NULL or ROAD_SURFACE_CODE is NULL 
	or ROAD_SURFACE_DESCRIPTION is NULL or LIGHTING_CONDITION_CODE is NULL or LIGHTING_CONDITION_DESCRIPTION is NULL or WEATHER_1_CODE is NULL or WEATHER_1_DESCRIPTION is NULL 
	or PRIMARY_CONTRIBUTING_CIRCUMSTANCE_CODE is NULL or PRIMARY_CONTRIBUTING_CIRCUMSTANCE_DESCRIPTION is NULL or [LATITUDE/LONGITUDE_Desc] is NULL

-- Analyzing how the type of road surface affects the amount of crashes

Select ROAD_SURFACE_DESCRIPTION, COUNT(CRASH_CLASSIFICATION_CODE) as NUMBER_OF_CRASHES
From VehicleAccidentDesc
Where ROAD_SURFACE_DESCRIPTION <> 'NA' and ROAD_SURFACE_DESCRIPTION <> 'Unknown'
Group by ROAD_SURFACE_DESCRIPTION
Order by NUMBER_OF_CRASHES Desc

-- Exploring the severity of the crash to the type of road surface using CTE table that classifies a crash as a light or severe crash

With CTE_Crash_Level as
(Select *,
Case
	When CRASH_CLASSIFICATION_CODE <= 2 Then 'Light Crash'
	Else 'Severe Crash'
End as SEVERITY_OF_CRASH
From VehicleAccidentDesc
Where CRASH_CLASSIFICATION_CODE in (1, 2, 3, 4)
)
Select ROAD_SURFACE_DESCRIPTION, SEVERITY_OF_CRASH, COUNT(CRASH_CLASSIFICATION_CODE) as NUMBER_OF_CRASHES
From CTE_Crash_Level
Where ROAD_SURFACE_DESCRIPTION not in ('NA', 'Other', 'Unknown')
Group by ROAD_SURFACE_DESCRIPTION, SEVERITY_OF_CRASH
Order by NUMBER_OF_CRASHES Desc

-- Creating a view that adds a column, SEVERITY_OF_CRASH, to not have to use a CTE tables multiple times

Drop View if Exists Severity_Crash;
Go
Create View Severity_Crash as
Select *,
Case
	When CRASH_CLASSIFICATION_CODE <= 2 Then 'Light Crash'
	Else 'Severe Crash'
End as SEVERITY_OF_CRASH
From VehicleAccidentDesc
Where CRASH_CLASSIFICATION_CODE in (1, 2, 3, 4);
Go

-- Looking at the severity of the crash to the road surface type again, but with the view instead of the CTE Table

Select ROAD_SURFACE_DESCRIPTION, SEVERITY_OF_CRASH, COUNT(CRASH_CLASSIFICATION_CODE) as NUMBER_OF_CRASHES
From Severity_Crash
Where ROAD_SURFACE_DESCRIPTION not in ('NA', 'Other', 'Unknown')
Group by ROAD_SURFACE_DESCRIPTION, SEVERITY_OF_CRASH
Order by NUMBER_OF_CRASHES Desc

-- Looking at the distribution of severe crashes by the road surface type

Select ROAD_SURFACE_DESCRIPTION, SEVERITY_OF_CRASH, COUNT(CRASH_CLASSIFICATION_CODE) as NUMBER_OF_CRASHES
From Severity_Crash
Where ROAD_SURFACE_DESCRIPTION not in ('NA', 'Other', 'Unknown') and SEVERITY_OF_CRASH = 'Severe Crash'
Group by ROAD_SURFACE_DESCRIPTION, SEVERITY_OF_CRASH
Order by NUMBER_OF_CRASHES Desc

-- Looking at the number of severe versus light crashes for each area of impact between two or more vehicles

Select MANNER_OF_IMPACT_DESCRIPTION, SEVERITY_OF_CRASH, COUNT(MANNER_OF_IMPACT_DESCRIPTION) as NUMBER_OF_CRASHES
From Severity_Crash
Where MANNER_OF_IMPACT_DESCRIPTION not in ('NA', 'Other', 'Unknown')
Group by MANNER_OF_IMPACT_DESCRIPTION, SEVERITY_OF_CRASH
Order by NUMBER_OF_CRASHES Desc

-- Looking at which day during the week has the most crashes for drivers under the influence

Select DAY_OF_WEEK_Inv, COUNT(ALCOHOL_INVOLVED) as DRINKING_WHILE_DRIVING_CRASHES
From VehicleAccidentInv
Where ALCOHOL_INVOLVED = 'Y'
Group by DAY_OF_WEEK_Inv
Order by DRINKING_WHILE_DRIVING_CRASHES Desc

-- Getting the datatypes from the tables

Select TABLE_NAME, COLUMN_NAME, DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'VehicleAccidentDesc' and COLUMN_NAME = 'CRASH_DATETIME_Desc'

-- Converting the Crash Datetime column from varchar to datetime

Drop Table if Exists #Accident_Datetime
Create Table #Accident_Datetime (
Crash_Datetime datetime,
Day_of_Week nvarchar(255),
Crash_Class_Code float,
Road_Type nvarchar(255),
Lighting_Condition nvarchar(255),
Weather nvarchar(255)
);

Insert into #Accident_Datetime
Select Format(CONVERT(datetime, substring(CRASH_DATETIME_Desc, 1, 19), 110), 'MM/dd/yyy HH:mm:ss') as Crash_Datetime,
	Day_of_Week_Desc, Crash_Classification_Code, Road_Surface_Description, Lighting_Condition_Description, Weather_1_Description
From VehicleAccidentDesc
Order by Crash_Datetime;

Drop Table if Exists #Accident_Datetime_2
Create Table #Accident_Datetime_2 (
Crash_Datetime datetime,
Day_of_Week nvarchar(255),
Crash_Class_Code float,
Road_Type nvarchar(255),
Lighting_Condition nvarchar(255),
Weather nvarchar(255),
"Year" int,
Light_or_Severe nvarchar(255)
);

Insert into #Accident_Datetime_2 (Crash_Datetime, Day_of_Week, Crash_Class_Code, Road_Type, Lighting_Condition, Weather, "Year", Light_or_Severe)
Select Crash_Datetime, Day_of_Week, Crash_Class_Code, Road_Type, Lighting_Condition, Weather, YEAR(Crash_Datetime),
Case
	When Crash_Class_Code <= 2 Then 'Light Crash'
	Else 'Severe Crash'
End as Light_or_Severe
From #Accident_Datetime
Where Crash_Class_Code in (1, 2, 3, 4);

Select *
From #Accident_Datetime_2
Order by Crash_Datetime

-- Counting the number of crashes per year using partition by

Select Crash_Datetime, "Year", 
COUNT(Crash_Datetime) OVER (PARTITION BY "Year" Order by "Year", Crash_Datetime) as Crashes_Per_Year
From #Accident_Datetime_2
Order by 2

-- Counting the number of crashes for each year for light or severe crashes

Select "Year", Light_or_Severe, COUNT(Crash_Datetime) as Numb_Crashes
From #Accident_Datetime_2
Group by "Year", Light_or_Severe
Order by Numb_Crashes Desc

-- Creating a view instead of a temp table with the Year column called Crashes_per_Year

Drop View if Exists Crashes_Desc;
Go
Create View Crashes_Desc as
Select CONVERT(datetime, substring(CRASH_DATETIME_Desc, 1, 19), 110) as CRASH_DATETIME, DAY_OF_WEEK_Desc, CRASH_CLASSIFICATION_CODE, ROAD_SURFACE_DESCRIPTION,
LIGHTING_CONDITION_DESCRIPTION, WEATHER_1_DESCRIPTION,
Case
	When CRASH_CLASSIFICATION_CODE > 2 then 'Severe_Crash'
	Else 'Light_Crash'
End as SEVERITY_OF_CRASH
From VehicleAccidentDesc
Go;


Drop View if Exists Crashes_Year;
Go
Create View Crashes_Year as
Select *, YEAR(CRASH_DATETIME) as CRASH_YEAR
From Crashes_Desc
Go;

Drop View if Exists Crashes_per_Year;
Go
Create View Crashes_per_Year as
Select CRASH_YEAR, SEVERITY_OF_CRASH, COUNT(CRASH_DATETIME) CRASH_COUNT
From Crashes_Year
Group by CRASH_YEAR, SEVERITY_OF_CRASH;
Go

Select *
From Crashes_per_Year

-- Joining the two tables, VehicleAccidentDescription and VehicleAccidentInvolvement, together

Drop View if Exists VehicleAccidents;
Go
Create View VehicleAccidents as
Select *
From VehicleAccidentDesc
Join VehicleAccidentInv
	on VehicleAccidentDesc.[CRASH_DATETIME_Desc] = VehicleAccidentInv.[CRASH_DATETIME_Inv]
	and VehicleAccidentDesc.[LATITUDE/LONGITUDE_Desc] = VehicleAccidentInv.[LATITUDE/LONGITUDE_Inv];
Go

-- Looking at the new join and checking if the tables joined correctly

Select *
From VehicleAccidents
Order by Crash_datetime_Desc

Select *
From VehicleAccidents
Where "CRASH_DATETIME_Desc" <> "CRASH_DATETIME_Inv"
Order by "CRASH_DATETIME_Desc"

-- Looking at the relationship between the weather and the number of pedestrian collisions from a car

Select WEATHER_1_DESCRIPTION, COUNT(PEDESTRIAN_INVOLVED) as PEDESTRIAN_COLLISION_COUNT
From VehicleAccidents
Where PEDESTRIAN_INVOLVED = 'Y' and WEATHER_1_DESCRIPTION Not in ('Unknown', 'Other')
Group by WEATHER_1_DESCRIPTION
Order by PEDESTRIAN_COLLISION_COUNT Desc

-- Analyzing the relationship of a seatbelt being used to the severity of the crash and the number of crashes

Select CRASH_CLASSIFICATION_CODE, SEATBELT_USED, COUNT(SEATBELT_USED) as CRASH_COUNT
From VehicleAccidents
Group by CRASH_CLASSIFICATION_CODE, SEATBELT_USED
Order by CRASH_COUNT Desc, CRASH_CLASSIFICATION_CODE Asc

-- Creating a view, VehicleAccidentsEverything, joining the VehicleAccidentInv and VehicleAccidentDesc with converting the data to the correct datatypes and adding new columns

Drop View if Exists VehicleAccidentsEverything;
Go
Create View VehicleAccidentsEverything as
Select CONVERT(datetime, substring(CRASH_DATETIME_Desc, 1, 19), 110) as Crash_Datetime, CONVERT(int, DAY_OF_WEEK_CODE_Desc) as DAY_OF_WEEK_CODE,
CONVERT(varchar, DAY_OF_WEEK_Desc) as DAY_OF_WEEK, CRASH_CLASSIFICATION_CODE, CRASH_CLASSIFICATION_DESCRIPTION, MANNER_OF_IMPACT_CODE, MANNER_OF_IMPACT_DESCRIPTION, 
ROAD_SURFACE_CODE, ROAD_SURFACE_DESCRIPTION, LIGHTING_CONDITION_CODE, LIGHTING_CONDITION_DESCRIPTION, WEATHER_1_CODE, WEATHER_1_DESCRIPTION, 
PRIMARY_CONTRIBUTING_CIRCUMSTANCE_CODE, PRIMARY_CONTRIBUTING_CIRCUMSTANCE_DESCRIPTION, COLLISION_ON_PRIVATE_PROPERTY, PEDESTRIAN_INVOLVED, 
ALCOHOL_INVOLVED, DRUG_INVOLVED, SEATBELT_USED, MOTORCYCLE_INVOLVED, MOTORCYCLE_HELMET_USED, BICYCLED_INVOLVED, BICYCLE_HELMET_USED, SCHOOL_BUS_INVOLVED, LONGITUDE, LATITUDE,
Case
	When DAY_OF_WEEK_Desc in ('Saturday', 'Sunday') then 'Weekend'
	Else 'Weekday'
End as WEEKEND_OR_WEEKDAY,
Case
	When CRASH_CLASSIFICATION_CODE <= 2 then 'Light Crash'
	Else 'Severe Crash'
End as SEVERE_OR_LIGHT_CRASH
From VehicleAccidents;
Go

Select *
From VehicleAccidentsEverything
