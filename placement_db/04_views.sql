-- 04_views.sql  creates the 9 views and shows their output

-- ===================== STUDENTS & ACADEMICS  (department, program, student) =====================
CREATE OR REPLACE VIEW v_dept_placement_summary AS
SELECT d.dept_id, d.dept_name,
       COUNT(DISTINCT s.student_id) AS total_students,
       COUNT(DISTINCT o.student_id) AS placed_students,
       ROUND(100.0 * COUNT(DISTINCT o.student_id) / NULLIF(COUNT(DISTINCT s.student_id), 0), 2) AS placement_pct
FROM department d
JOIN student s    ON s.dept_id = d.dept_id
LEFT JOIN offer o ON o.student_id = s.student_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM v_dept_placement_summary ORDER BY placement_pct DESC, dept_name;

SELECT dept_name, placement_pct
FROM v_dept_placement_summary
WHERE placement_pct < (SELECT 100.0 * SUM(placed_students) / SUM(total_students) FROM v_dept_placement_summary);

-- ===================== COMPANIES & JOBS  (company, job_profile, eligibility_criteria, eligibility_dept) =====================
CREATE OR REPLACE VIEW v_eligible_students AS
SELECT c.company_id, c.company_name, j.job_id, j.role_title, s.student_id, s.student_name, s.dept_id, s.cgpa
FROM job_profile j
JOIN company c               ON c.company_id = j.company_id
JOIN eligibility_criteria ec ON ec.job_id = j.job_id
JOIN eligibility_dept ed     ON ed.criteria_id = ec.criteria_id
JOIN student s               ON s.dept_id = ed.dept_id
WHERE s.cgpa >= ec.min_cgpa
  AND s.backlogs <= ec.max_backlogs;

CREATE OR REPLACE VIEW v_company_recruitment AS
SELECT c.company_id, c.company_name,
       COUNT(DISTINCT j.job_id) AS job_profiles,
       COUNT(o.offer_id)        AS offers_made,
       MAX(j.package_lpa)       AS best_package_lpa
FROM company c
JOIN job_profile j      ON j.company_id = c.company_id
LEFT JOIN application a ON a.job_id = j.job_id
LEFT JOIN offer o       ON o.application_id = a.application_id
GROUP BY c.company_id, c.company_name;

SELECT company_name, role_title, student_id, cgpa FROM v_eligible_students ORDER BY company_name, role_title, cgpa DESC;
SELECT * FROM v_company_recruitment ORDER BY offers_made DESC, company_name;

-- ===================== DRIVES & APPLICATIONS  (placement_drive, application) =====================
CREATE OR REPLACE VIEW v_company_selection_rate AS
SELECT c.company_id, c.company_name,
       COUNT(a.application_id) AS applications,
       SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) AS selected,
       ROUND(100.0 * SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) / COUNT(a.application_id), 2) AS selection_rate_pct
FROM company c
JOIN placement_drive pd ON pd.company_id = c.company_id
JOIN application a      ON a.drive_id = pd.drive_id
GROUP BY c.company_id, c.company_name;

CREATE OR REPLACE VIEW v_application_details AS
SELECT a.application_id, a.student_id, s.student_name, c.company_name, j.role_title, pd.drive_id, pd.drive_date, a.status
FROM application a
JOIN student s          ON s.student_id = a.student_id
JOIN job_profile j      ON j.job_id = a.job_id
JOIN placement_drive pd ON pd.drive_id = a.drive_id
JOIN company c          ON c.company_id = pd.company_id;

SELECT * FROM v_company_selection_rate ORDER BY selection_rate_pct DESC;
SELECT * FROM v_application_details ORDER BY application_id;

-- ===================== SELECTION PROCESS & READINESS  (aptitude_test, interview) =====================
CREATE OR REPLACE VIEW v_readiness_indicators AS
SELECT s.student_id, d.dept_name AS department, s.cgpa,
       COALESCE((SELECT ROUND(AVG(t.score), 1) FROM aptitude_test t WHERE t.student_id = s.student_id), 0) AS aptitude_score,
       (SELECT COUNT(*) FROM interview i JOIN application a ON a.application_id = i.application_id
         WHERE a.student_id = s.student_id AND i.result = 'Pass') AS interview_success,
       (SELECT COUNT(*) FROM interview i JOIN application a ON a.application_id = i.application_id
         WHERE a.student_id = s.student_id) AS interview_rounds,
       (SELECT COUNT(*) FROM offer o WHERE o.student_id = s.student_id) AS offers
FROM student s
JOIN department d ON d.dept_id = s.dept_id;

CREATE OR REPLACE VIEW v_placement_readiness AS
SELECT student_id, department, cgpa, aptitude_score, interview_success, offers,
       ROUND(0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100), 1) AS readiness_score,
       CASE
           WHEN cgpa < 6.0 OR aptitude_score < 40 THEN 'NEEDS INTERVENTION'
           WHEN (0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100)) >= 75 THEN 'PLACEMENT READY'
           WHEN (0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100)) >= 60 THEN 'MODERATELY READY'
           WHEN (0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100)) >= 45 THEN 'NEEDS TRAINING'
           ELSE 'NEEDS INTERVENTION'
       END AS readiness
FROM v_readiness_indicators;

SELECT * FROM v_placement_readiness ORDER BY readiness_score DESC;

SELECT student_id AS student, department, cgpa, aptitude_score, interview_success, offers, readiness
FROM v_placement_readiness
WHERE student_id IN ('S101', 'S205')
ORDER BY student_id;

SELECT department, readiness, COUNT(*) AS students
FROM v_placement_readiness
GROUP BY department, readiness
ORDER BY department, readiness;

-- ===================== OFFERS & JOINING  (offer, joining_status) =====================
CREATE OR REPLACE VIEW v_offer_details AS
SELECT o.offer_id, s.student_id, s.student_name, d.dept_name, c.company_name, j.role_title,
       o.package_lpa, o.offer_date, js.status AS joining_status
FROM offer o
JOIN student s          ON s.student_id = o.student_id
JOIN department d       ON d.dept_id = s.dept_id
JOIN application a      ON a.application_id = o.application_id
JOIN job_profile j      ON j.job_id = a.job_id
JOIN company c          ON c.company_id = j.company_id
LEFT JOIN joining_status js ON js.offer_id = o.offer_id;

CREATE OR REPLACE VIEW v_package_summary AS
SELECT d.dept_name,
       COUNT(o.offer_id)            AS offers,
       COUNT(DISTINCT o.student_id) AS students_with_offers,
       ROUND(AVG(o.package_lpa), 2) AS avg_package_lpa,
       MAX(o.package_lpa)           AS highest_package_lpa,
       MIN(o.package_lpa)           AS lowest_package_lpa
FROM offer o
JOIN student s    ON s.student_id = o.student_id
JOIN department d ON d.dept_id = s.dept_id
GROUP BY d.dept_name;

SELECT * FROM v_offer_details ORDER BY package_lpa DESC, student_id;
SELECT * FROM v_package_summary ORDER BY avg_package_lpa DESC;

