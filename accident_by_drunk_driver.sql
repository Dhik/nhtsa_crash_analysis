select
case
when number_of_drunk_drivers = 0 then 'Tidak Mabuk'
when number_of_drunk_drivers = 1 then 'Mabuk'
else 'error'
end kondisi_pengemudi,
count(*)*100/cast((select count(*) from crash)as float) percentage
from crash
group by number_of_drunk_drivers;


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