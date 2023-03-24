WITH crash_cleansing AS				--Data Cleansing
(
SELECT 	*
FROM 	crash
WHERE 	milepoint NOT IN (99999, 99998)
AND		land_use_name NOT IN ('Unknown', 'Not Reported')
AND		functional_system_name NOT IN ('Unknown', 'Not Reported')
AND		type_of_intersection_name NOT IN ('Not Reported')
AND		atmospheric_conditions_1_name NOT IN ('Not Reported')
ORDER BY 1 DESC
),

a AS							--Mencari tanggal awal data kecelakaan
(
SELECT	timestamp_of_crash last_date
FROM crash_cleansing
ORDER BY 1 DESC
LIMIT 1
),

x AS
(
SELECT	COUNT(*) total_kecelakaan	--Mencari total kecelakaan
FROM crash_cleansing
)

SELECT 	DISTINCT b.d_number nomor_hari_kecelakaan,	--nomer hari digunakan untuk
		(CASE										--menentukan hari kecelakaan
		WHEN b.d_number = 1 THEN 'Jumat'
		WHEN b.d_number = 0 THEN 'Sabtu'
		WHEN b.d_number = 6 THEN 'Minggu'
		WHEN b.d_number = 5 THEN 'Senin'
		WHEN b.d_number = 4 THEN 'Selasa'
		WHEN b.d_number = 3 THEN 'Rabu'
		WHEN b.d_number = 2 THEN 'Kamis'
		END) hari_kecelakaan,
		COUNT(b.consecutive_number) jumlah_kecelakaan,
		(COUNT(b.consecutive_number)::float/x.total_kecelakaan::float)*100 persentase_kecelakaan
FROM
----------------------------------------Sub Query-------------------------------------------------
(
SELECT 	crash_cleansing.consecutive_number,
	
-----mencari total periode analisa kecelakaan dari awal kecelakaan sampai data terakhir masuk-----
---------------dan mengambil sisa dari pembagian untuk menentukan hari----------------------------
	
		DATE_PART('day', (date_trunc('day',a.last_date)-date_trunc('day',crash_cleansing.timestamp_of_crash)))::float - 		
		(7 * trunc (DATE_PART('day', (date_trunc('day',a.last_date)-date_trunc('day',crash_cleansing.timestamp_of_crash)))/7)) d_number  
		
FROM a, crash_cleansing
GROUP BY crash_cleansing.consecutive_number, a.last_date, crash_cleansing.timestamp_of_crash
ORDER BY d_number
) b, x
GROUP BY nomor_hari_kecelakaan, hari_kecelakaan, x.total_kecelakaan
ORDER BY 1;