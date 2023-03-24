/*Jumlah Orang Terlibat Kecelakaan dan Korban Meninggal Berdasarkan Jenis Kecelakaan*/
SELECT 
	manner_of_collision_name,
	SUM(number_of_persons_in_motor_vehicles_in_transport_mvit) Orang_dalam_Kendaraan,
	SUM(number_of_persons_not_in_motor_vehicles_in_transport_mvit) Orang_tidak_dalam_Kendaraan,
	SUM(number_of_persons_in_motor_vehicles_in_transport_mvit+number_of_persons_not_in_motor_vehicles_in_transport_mvit) Jumlah_total_terlibat_kecelakaan,
	SUM(number_of_fatalities) jumlah_yang_meninggal
FROM crash
WHERE manner_of_collision_name NOT IN ('Reported as Unknown',
									  'Not Reported')
GROUP BY manner_of_collision_name
ORDER BY jumlah_korban DESC; 