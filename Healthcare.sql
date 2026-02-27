create database healthcare_db;
use healthcare_db;

select * from appointments; -- appointment_id	patient_id	doctor_id	appointment_date	reason	status
select * from diagnoses; -- diagnosis_id	patient_id	doctor_id	diagnosis_date	diagnosis	treatment
select * from doctors; -- doctor_id	name	specialization	experience_years	contact_number
select * from medications; -- medication_id	diagnosis_id	medication_name	dosage	start_date	end_date
select * from patients; -- patient_id	name	age	gender	address	contact_number
/*
Inner and Equi Joins 
Task: Write a query to fetch details of all completed appointments, including the 
patient’s name, doctor’s name, and specialization. 
 Expected Learning: Demonstrates understanding of Inner Joins and filtering 
conditions. 
*/
select ap.appointment_id, ap.patient_id, pt.name as patient_name, ap.doctor_id, doc.name as doctrs_name, doc.specialization, ap.status
from appointments ap
inner join patients pt on pt.patient_id = ap.patient_id
inner join doctors doc on doc.doctor_id = ap.doctor_id
where ap.status = 'Completed';

/*
Left Join with Null Handling 
Task: Retrieve all patients who have never had an appointment. Include their name, 
contact details, and address in the output. 
 Expected Learning: Use of Left Joins and handling NULL values. 
 */
 select pt.patient_id, pt.name as patient_name, pt.address, pt.contact_number
 from patients pt
 left join appointments apt on apt.patient_id = pt.patient_id
 where apt.status is null;
 
 /*
Right Join and Aggregate Functions 
Task: Find the total number of diagnoses for each doctor, including doctors who 
haven’t diagnosed any patients. Display the doctor’s name, specialization, and total 
diagnoses.  Expected Learning: Utilization of 
Right Joins with aggregate functions like COUNT(). 
 */
 select doc.name as doctors_name, doc.specialization, count(dgn.diagnosis_id) as total_diagnoses
 from diagnoses dgn
 right join doctors doc on doc.doctor_id = dgn.doctor_id
 group by doc.name, doc.specialization;
 
 /*
Full Join for Overlapping Data 
Task: Write a query to identify mismatches between the appointments and diagnoses 
tables. Include all appointments and diagnoses with their corresponding patient and 
doctor details. 
 Expected Learning: Handling Full Joins for comparing data across multiple tables. 
 */
 SELECT a.appointment_id, p.name AS patient_name, d.name AS doctor_name, a.appointment_date, a.status, di.diagnosis
FROM appointments a
LEFT JOIN diagnoses di ON a.patient_id = di.patient_id AND a.doctor_id = di.doctor_id
LEFT JOIN patients p ON a.patient_id = p.patient_id
LEFT JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE di.diagnosis_id IS NULL

UNION

SELECT a.appointment_id, p.name AS patient_name, d.name AS doctor_name, a.appointment_date, a.status, di.diagnosis
FROM appointments a
RIGHT JOIN diagnoses di ON a.patient_id = di.patient_id AND a.doctor_id = di.doctor_id
LEFT JOIN patients p ON di.patient_id = p.patient_id
LEFT JOIN doctors d ON di.doctor_id = d.doctor_id
WHERE a.appointment_id IS NULL;

 /*
Window Functions (Ranking and Aggregation) 
Task: For each doctor, rank their patients based on the number of appointments in 
descending order. 
 Expected Learning: Application of Ranking Functions such as RANK() or 
DENSE_RANK(). 
*/
SELECT d.name AS doctor_name, p.name AS patient_name, COUNT(a.appointment_id) AS total_appointments,
    RANK() OVER (
        PARTITION BY d.doctor_id
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS patient_rank
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY d.doctor_id, d.name, p.patient_id, p.name;

/*
Conditional Expressions 
Task: Write a query to categorize patients by age group (e.g., 18-30, 31-50, 51+). Count 
the number of patients in each age group. 
 Expected Learning: Using CASE statements for conditional logic. 
 */
 SELECT
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '51+'
    END AS age_group,
    COUNT(*) AS total_patients
FROM patients
GROUP BY age_group
ORDER BY age_group;

 /*
Numeric and String Functions 
Task: Retrieve a list of patients whose contact numbers end with "1234" and display 
their names in uppercase. 
 Expected Learning: Use of string functions like UPPER() and LIKE. 
 */
SELECT UPPER(name) AS patient_name, contact_number
FROM patients
WHERE contact_number LIKE '%1234';

 /*
Subqueries for Filtering 
Task: Find patients who have only been prescribed "Insulin" 
in any of their diagnoses. 
 Expected Learning: Writing Subqueries for advanced filtering. 
 */
SELECT DISTINCT p.patient_id, p.name AS patient_name
FROM patients p
JOIN diagnoses d ON p.patient_id = d.patient_id
JOIN medications m ON d.diagnosis_id = m.diagnosis_id
WHERE m.medication_name = 'Insulin' AND p.patient_id NOT IN (
															SELECT d2.patient_id
															FROM diagnoses d2
															JOIN medications m2 ON d2.diagnosis_id = m2.diagnosis_id
															WHERE m2.medication_name <> 'Insulin');

 /*
Date and Time Functions 
Task: Calculate the average duration (in days) for which medications are prescribed 
for each diagnosis. 
 Expected Learning: Working with date functions like DATEDIFF().
 */
SELECT d.diagnosis_id, d.diagnosis, AVG(DATEDIFF(m.end_date, m.start_date)) AS avg_medication_duration_days
FROM diagnoses d
JOIN medications m ON d.diagnosis_id = m.diagnosis_id
GROUP BY d.diagnosis_id, d.diagnosis;

 /*
 Complex Joins and Aggregation 
Task: Write a query to identify the doctor who has attended the most unique patients. 
Include the doctor’s name, specialization, and the count of unique patients. 
 Expected Learning: Combining Joins, Grouping, and COUNT(DISTINCT). 
 */
SELECT d.name AS doctor_name, d.specialization, COUNT(DISTINCT a.patient_id) AS unique_patient_count
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name, d.specialization
ORDER BY unique_patient_count DESC
LIMIT 1;

 