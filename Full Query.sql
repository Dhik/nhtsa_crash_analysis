
-- Temukan persentase kecelakaan yang diakibatkan oleh pengemudi mabuk
--cleaning
-- delete from crash where milepoint > 10000;

--check data
select x.hasil_validasi, count(*) from (
select city_name, milepoint,
    case
    
    when city_name IN ('NOT APPLICABLE', 'Not Reported', 'Unknown') 
    then 'error city name'

    when land_use_name IN ('Not Reported', 'Unknown')
    then 'error land use'
	when functional_system_name IN ('Not Reported', 'Unknown') 
    then 'error func name'
	when milepoint > 10000
    then 'error milepoint'
	when type_of_intersection_name IN ('Reported as Unknown', 'Not Reported')
    then 'error type intersec'

    else 'OK'
    end hasil_validasi

from crash
) x group by hasil_validasi
order by count(*) desc;









--processing
--mengubah kolom jumlah pemabuk menjadi bernilai true or false
update crash set number_of_drunk_drivers= 1 where number_of_drunk_drivers > 1;
--answer
--menghitung persentase setiap kejadian (insight: persentase kecelakaan diakibatkan pengendara mabuk)
select
case
when number_of_drunk_drivers = 0 then 'Tidak Mabuk'
when number_of_drunk_drivers = 1 then 'Mabuk'
else 'error'
end kondisi_pengemudi,
count(*)*100/cast((select count(*) from crash)as float) percentage
from crash
group by number_of_drunk_drivers;


--Titik KM yang sering terjadi kecelakaan dan mengakibatkan kematian (selidiki penyebab di KM tersebut terjadi kecelakaan)
select milepoint, count(*) from crash
group by milepoint
order by count(*) desc
limit 5;

select milepoint, manner_of_collision_name, count(*) from crash
where milepoint in (
	select milepoint from crash
	group by milepoint
	order by count(*) desc
	limit 5
)group by milepoint, manner_of_collision_name;

select milepoint, manner_of_collision_name, sum(number_of_fatalities) from crash
where milepoint in (
	select milepoint from crash
	group by milepoint
	order by count(*) desc
	limit 5
)group by milepoint, manner_of_collision_name;


--Hubungan cara tabrakan dengan kondisi
select manner_of_collision_name, count(*) from crash
group by manner_of_collision_name
order by count(*) desc;

select manner_of_collision_name, light_condition_name, count(*) from crash
group by manner_of_collision_name, light_condition_name
order by count(*) desc;

select manner_of_collision_name, atmospheric_conditions_1_name, count(*) from crash
group by manner_of_collision_name, atmospheric_conditions_1_name
order by count(*) desc;


select number_of_drunk_drivers, sum(number_of_fatalities)/cast((select count(*) from crash)as float) percentage from crash
group by number_of_drunk_drivers
order by percentage desc;

select 
manner_of_collision_name, 
case
when number_of_drunk_drivers = 0 then 'Tidak Mabuk'
when number_of_drunk_drivers = 1 then 'Mabuk'
else 'error'
end kondisi_pengemudi, 
count(*) from crash
group by manner_of_collision_name, kondisi_pengemudi
order by count(*) desc;

select manner_of_collision_name, sum(number_of_fatalities)/cast((select count(*) from crash)as float) percentage from crash
group by manner_of_collision_name
order by sum(number_of_fatalities) desc;

-- rata-rata jam terjadi kecelakaan 
select extract(hour from timestamp_of_crash) hours, count(*), count(*)*100/cast((select count(*) from crash)as float) percentage
from crash 
group by hours
order by count(*) desc;

--Persentase kecelakaan berdasarkan hari kecelakaan terjadi
select to_char(timestamp_of_crash, 'YYYY-MM-DD') days, 
COUNT(consecutive_number),
COUNT(consecutive_number)*100/cast((select count(consecutive_number) from crash)as float) percentage
from crash
group by to_char(timestamp_of_crash, 'YYYY-MM-DD')
order by to_char(timestamp_of_crash, 'YYYY-MM-DD');

-- Temukan kondisi yang memperbesar risiko kecelakaan
SELECT 
	light_condition_name,
	atmospheric_conditions_1_name,
	number_of_drunk_drivers,
	COUNT(consecutive_number) angka_kecelakaan,
	SUM(number_of_fatalities) jumlah_korban
FROM crash
WHERE 
	manner_of_collision_name NOT IN ('Reported as Unknown','Not Reported') 
	AND
	light_condition_name NOT IN ('Reported as Unknown', 'Not Reported') 
	AND
	atmospheric_conditions_1_name NOT IN ('Not Reported', 'Reported as Unknown') 
GROUP BY 
	light_condition_name,
	atmospheric_conditions_1_name,
	number_of_drunk_drivers
ORDER BY jumlah_korban DESC;

-- Temukan persentase kecelakaan di daerah perkotaan dan pedesaan
select land_use_name, count(*)*100/cast((select count(*) from crash)as float) percentage from crash
group by land_use_name;



/*Hubungan Cara Tabrakan dengan kondisi dan waktu kecelakaan */
SELECT 
	manner_of_collision_name,
	light_condition_name,
	atmospheric_conditions_1_name,
	extract(hour from timestamp_of_crash) hours,
	SUM(number_of_fatalities) jumlah_korban
FROM crash
WHERE 
	manner_of_collision_name NOT IN ('Reported as Unknown', 'Not Reported') 
	AND
	light_condition_name NOT IN ('Reported as Unknown', 'Not Reported') 
	AND
	atmospheric_conditions_1_name NOT IN ('Not Reported', 'Reported as Unknown') 
GROUP BY 
	manner_of_collision_name,
	light_condition_name,
	atmospheric_conditions_1_name,
	extract(hour from timestamp_of_crash)
ORDER BY jumlah_korban DESC;





------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--Mendapatkan jumlah hari sejumlah banyak baris yang ada berdasarkan jam
select extract(hour from timestamp_of_crash) jam,
	extract(day from (max(timestamp_of_crash) over() - min(timestamp_of_crash) over())) total_hari
	from crash


select jam, count(1)/avg(total_hari) percentage  --kenapa avg karena semua nilainya sama 364
FROM
	(select extract(hour from timestamp_of_crash) jam,
	extract(day from (max(timestamp_of_crash) over() - min(timestamp_of_crash) over())) total_hari
	from crash) x
GROUP BY jam
order by jam;


SELECT
	state_name,
	COUNT(consecutive_number) angka_kecelakaan
FROM crash
GROUP BY state_name
ORDER BY angka_kecelakaan DESC
LIMIT 10;


select
case
when state_name = 'California' then timestamp_of_crash at time zone 'pst'
when state_name = 'Texas' then timestamp_of_crash at time zone 'mdt'
when state_name = 'Georgia' then timestamp_of_crash at time zone 'edt'
when state_name = 'North Carolina' then timestamp_of_crash at time zone 'edt'
when state_name = 'Ohio' then timestamp_of_crash at time zone 'edt'
else timestamp_of_crash
end time_baru
from crash
where state_name in ('California', 'Texas', 'Georgia', 'North Carolina', 'Ohio');



-- Persentase kecelakaan perjam
select extract(hour from time_baru) jam, count(1)/avg(total_hari) percentage 
from 
(select state_name, timestamp_of_crash, extract(day from (max(timestamp_of_crash) over() - min(timestamp_of_crash) over())) total_hari,
case
when state_name = 'California' then timestamp_of_crash at time zone 'pst'
when state_name = 'Texas' then timestamp_of_crash at time zone 'mdt'
when state_name = 'Georgia' then timestamp_of_crash at time zone 'edt'
when state_name = 'North Carolina' then timestamp_of_crash at time zone 'edt'
when state_name = 'Ohio' then timestamp_of_crash at time zone 'edt'
else timestamp_of_crash
end time_baru
from crash) x
where state_name in ('California', 'Texas', 'Georgia', 'North Carolina', 'Ohio')
GROUP BY jam
order by jam;



select extract(hour from time_baru) jam, count(1)/avg(total_hari) percentage 
from 
(select number_of_drunk_drivers, state_name, timestamp_of_crash, extract(day from (max(timestamp_of_crash) over() - min(timestamp_of_crash) over())) total_hari,
case
when state_name = 'California' then timestamp_of_crash at time zone 'pst'
when state_name = 'Texas' then timestamp_of_crash at time zone 'mdt'
when state_name = 'Georgia' then timestamp_of_crash at time zone 'edt'
when state_name = 'North Carolina' then timestamp_of_crash at time zone 'edt'
when state_name = 'Ohio' then timestamp_of_crash at time zone 'edt'
else timestamp_of_crash
end time_baru
from crash) x
where state_name in ('California', 'Texas', 'Georgia', 'North Carolina', 'Ohio')
and number_of_drunk_drivers = 1
GROUP BY jam
order by jam;




----------------------------------
SELECT 
	light_condition_name,
	atmospheric_conditions_1_name,
	COUNT(consecutive_number) angka_kecelakaan
FROM crash
where light_condition_name in (
	select light_condition_name from crash 
	group by light_condition_name
	order by COUNT(consecutive_number) desc
	limit 5
)
and atmospheric_conditions_1_name in (
	select atmospheric_conditions_1_name from crash 
	group by atmospheric_conditions_1_name
	order by COUNT(consecutive_number) desc
	limit 5
)
GROUP BY 
	light_condition_name,
	atmospheric_conditions_1_name
ORDER BY angka_kecelakaan DESC;




select case
when number_of_drunk_drivers = 0 then 'Tidak Mabuk'
when number_of_drunk_drivers = 1 then 'Mabuk'
else 'error'
end kondisi_pengemudi, 
sum(number_of_fatalities) jumlah_korban, 
count(*) from crash
group by kondisi_pengemudi;




select case
when number_of_drunk_drivers = 0 then 'Tidak Mabuk'
when number_of_drunk_drivers = 1 then 'Mabuk'
else 'error'
end kondisi_pengemudi, 
state_name, 
count(*) from crash
where state_name in (
	SELECT
	state_name
	FROM crash
	GROUP BY state_name
	ORDER BY COUNT(consecutive_number) DESC
	LIMIT 5
)
group by state_name, kondisi_pengemudi
order by count(*) desc;