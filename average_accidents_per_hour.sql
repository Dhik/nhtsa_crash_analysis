WITH crash_cleansing AS							--Cleansing data
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

a AS										--mencari data pertama masuk
(											--di gunakan untuk periode awal analisis
SELECT	timestamp_of_crash AS first_date
FROM crash_cleansing
ORDER BY 1 ASC
LIMIT 1
),

b AS										--mencari data terakhir masuk
(											--di gunakan untuk periode akhir analisis
SELECT	timestamp_of_crash AS last_date
FROM crash_cleansing
ORDER BY 1 DESC
LIMIT 1
),

c As										--mencari periode analisis dalam satuan jam
(
SELECT	(EXTRACT('day' FROM (b.last_date - a.first_date)) * 24) + 
		(EXTRACT('hour' FROM (b.last_date - a.first_date))) Total_Jam_Periode
FROM a,b
),

urban AS										--mencari total kecelakaan di kota
(
SELECT COUNT (crash_cleansing.consecutive_number) Total_Kecelakaan_Urban
FROM crash_cleansing
WHERE land_use_name = 'Urban'
),

rural AS										--mencari total kecelakaan di perdesaan
(
SELECT COUNT (crash_cleansing.consecutive_number) Total_Kecelakaan_Rural
FROM crash_cleansing
WHERE land_use_name = 'Rural'
)

SELECT	c.Total_Jam_Periode,
		
		COUNT (crash_cleansing.consecutive_number) Total_Kecelakaan,
		
		(COUNT (crash_cleansing.consecutive_number) / c.Total_Jam_Periode) rata_rata_kecelakaan_per_jam,
		
		((urban.Total_Kecelakaan_Urban/ (c.Total_Jam_Periode))) rata_rata_kecelakaan_per_jam_di_perkotaan,
		
		((rural.Total_Kecelakaan_Rural/ (c.Total_Jam_Periode))) rata_rata_kecelakaan_per_jam_di_perdesaan
		
FROM a, b, c, urban, rural, crash_cleansing
GROUP BY 	b.last_date, 
			a.first_date, 
			urban.Total_Kecelakaan_Urban, 
			rural.Total_Kecelakaan_Rural,
			c.Total_Jam_Periode
;