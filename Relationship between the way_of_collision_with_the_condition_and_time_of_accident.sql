/* Cara Tabrakan */

SELECT 
	manner_of_collision_name, 
	SUM(number_of_fatalities) jumlah_korban
FROM crash
WHERE manner_of_collision_name NOT IN ('Reported as Unknown',
									  'Not Reported')
GROUP BY manner_of_collision_name
ORDER BY jumlah_korban DESC;

/*Hubungan Cara Tabrakan dengan kondisi dan waktu kecelakaan */
SELECT 
	manner_of_collision_name,
	light_condition_name,
	atmospheric_conditions_1_name,
	timestamp_of_crash,
	SUM(number_of_fatalities) jumlah_korban
FROM crash
WHERE 
	manner_of_collision_name NOT IN ('Reported as Unknown',
									  'Not Reported') 
	AND
	light_condition_name NOT IN ('Reported as Unknown',
								 'Not Reported') 
	AND
	atmospheric_conditions_1_name NOT IN ('Not Reported',
										  'Reported as Unknown') 
GROUP BY 
	manner_of_collision_name,
	light_condition_name,
	atmospheric_conditions_1_name,
	timestamp_of_crash
ORDER BY jumlah_korban DESC;
