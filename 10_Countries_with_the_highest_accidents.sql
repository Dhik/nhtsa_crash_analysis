/*Temukan 10 Negara bagian teratas 
dengan angka kecelakaan tertinggi */

SELECT
	state_name,
	COUNT(consecutive_number) angka_kecelakaan
FROM crash
WHERE 
	city_name NOT IN ('NOT APPLICABLE',
					  'Not Reported',
					  'Unknown') 
	AND
	land_use_name NOT IN ('Not Reported',
						  'Unknown') 
	AND
	functional_system_name NOT IN ('Not Reported',
								   'Unknown') 
	AND
	milepoint NOT IN (99999,99998) 
	AND
	type_of_intersection_name NOT IN ('Reported as Unknown',
									  'Not Reported')	
GROUP BY state_name
ORDER BY angka_kecelakaan DESC
LIMIT 10;