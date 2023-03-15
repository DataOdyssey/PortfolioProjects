select * from sexratio_literacy

select * from population

-- Number of rows in dataset

select count(*) from sexratio_literacy
select count(*) from population

-- Dataset for jharkhand and Bihar

select * from sexratio_literacy
where State in ('jharkand', 'Bihar')

-- Total Population of data

select sum(population) as total_population from population

--Average growth of every state

select state,avg(growth)*100 as avg_growth 
from sexratio_literacy
group by State
order by avg_growth desc

-- States with Average literacy rate more than 90

select state, round(avg(literacy), 0) as avg_literacy_ratio 
from sexratio_literacy
group by state
having round(avg(literacy), 0) > 90
order by avg_literacy_ratio  desc

-- top 3 states showing highest growth ratio

select top 3 state,avg(growth)*100 as avg_growth 
from sexratio_literacy
group by State
order by avg_growth desc

-- bottom 3 states showing lowest growth ratio

select top 3 state,avg(growth)*100 as avg_growth 
from sexratio_literacy
group by State
order by avg_growth asc

-- displaying top 3 states and bottom 3 states in literacy rate

drop table if exists topstates
create table topstates 
( 
state nvarchar(255),
topstates float
)

insert into topstates
select state, round(avg(literacy), 0) as avg_literacy_ratio 
from sexratio_literacy
group by state
order by avg_literacy_ratio  desc

drop table if exists bottomstates
create table bottomstates 
( 
state nvarchar(255),
bottomstates float
)


insert into bottomstates
select state, round(avg(literacy), 0) as avg_literacy_ratio 
from sexratio_literacy
group by state
order by avg_literacy_ratio  desc

select * from(
select top 3 * from topstates order by topstates desc) a
union 
select * from(
select top 3 * from bottomstates order by bottomstates asc) b


-- States starting with letter 'a' or 'b'

select distinct state from sexratio_literacy where state like'a%' or state like 'b%'

-- States starting with letter 'a' and ending with 'm'

select distinct state from sexratio_literacy where state like'a%' and state like '%m'

-- Total Male and Total Female Population District wise

select d.state, sum(d.males) as Total_males, sum(d.females) as Total_females 
from
(select c.District, c.state, round(c.Population / (sex_ratio+1), 0) as males, round((c.Population * c.Sex_Ratio) / (Sex_Ratio+1), 0) as females 
from
(select a.district, a.state, sex_ratio/1000 as sex_ratio, population
from sexratio_literacy  a
inner join population b on a.District = b.District) c) d
group by d.state

-- Total Literacy rate District wise

select d.state, sum(Literate_people) as Total_literate_people, sum(illiterate_people) as Total_illiterate
from
(select c.district, c.state, round( c.literacy_ratio * c.population, 0) as Literate_people, round((1 - c.literacy_ratio) * c.population, 0) as Illiterate_people 
from
(select a.district, a.state, a.Literacy/100 as Literacy_ratio, b.Population
from sexratio_literacy  a
inner join population b on a.District = b.District)c)d
group by d.state

-- Population in previous Census

select sum(f.previous_census_population) as previous_year_population, sum(f.current_census_population) as current_year_population
from
(select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population ) as current_census_population 
from
(select d.district, d.state, round(d.Population / (1 + d.growth), 0) as previous_census_population, d.population as current_census_population
from
(
select a.district, a.state, a.growth, b.population 
from sexratio_literacy a
inner join population b on a.district = b.district 
) d) e 
group by e.State) f

-- Population vs Area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area 
from
(select q.*,r.total_area 
from 
(select '1' as keyy,n.* 
from
(select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population) as current_census_population 
from
(select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population 
from
(select d.district,d.state,round(d.population/(1+d.growth),0) as previous_census_population,d.population as current_census_population 
from
(select a.district,a.state,a.growth growth,b.population from sexratio_literacy a inner join population b on a.district=b.district) d) e
group by e.state)m) n) q 
inner join 
(select '1' as keyy,z.* from (select sum(area_km2) as total_area from population)z) r on q.keyy=r.keyy) g


-- Output top 3 districts from each state with highest literacy rate

select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) as rnk from sexratio_literacy) a

where a.rnk in (1,2,3) order by state