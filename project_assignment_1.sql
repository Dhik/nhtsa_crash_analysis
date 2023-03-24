/*kondisi yang memperbesar risiko kecelakaan */



select light_condition_name, 
       atmospheric_conditions_1_name, 
	   count(*) jumlah_kecelakaan,
	   sum(number_of_fatalities) as jumlah_korban_kecelakaan

from   crash 
where  light_condition_name not in ('Not Reported','Reported as Unknown')
and    atmospheric_conditions_1_name not in ('Not Reported','Reported as Unknown')
group by light_condition_name , atmospheric_conditions_1_name
order by jumlah_korban_kecelakaan desc;









