-- 03_queries.sql  all analysis queries, plus modification and deletion demos

-- ===================== STUDENTS & ACADEMICS  (department, program, student) =====================
-- Q1 Students per department and program, with average CGPA
SELECT d.dept_name, p.program_name, COUNT(s.student_id) AS students, ROUND(AVG(s.cgpa), 2) AS avg_cgpa
FROM department d
JOIN program p      ON p.dept_id = d.dept_id
LEFT JOIN student s ON s.program_id = p.program_id
GROUP BY d.dept_name, p.program_name
ORDER BY d.dept_name, p.program_name;

-- Q2 Department-wise placement percentage (placed = at least one row in offer)
SELECT d.dept_id, d.dept_name,
       COUNT(DISTINCT s.student_id) AS total_students,
       COUNT(DISTINCT o.student_id) AS placed_students,
       ROUND(100.0 * COUNT(DISTINCT o.student_id) / NULLIF(COUNT(DISTINCT s.student_id), 0), 2) AS placement_pct
FROM department d
JOIN student s    ON s.dept_id = d.dept_id
LEFT JOIN offer o ON o.student_id = s.student_id
GROUP BY d.dept_id, d.dept_name
ORDER BY placement_pct DESC, d.dept_name;

-- Q3 University placement percentage
SELECT COUNT(DISTINCT s.student_id) AS total_students,
       COUNT(DISTINCT o.student_id) AS placed_students,
       ROUND(100.0 * COUNT(DISTINCT o.student_id) / COUNT(DISTINCT s.student_id), 2) AS university_pct
FROM student s
LEFT JOIN offer o ON o.student_id = s.student_id;

-- Q4 Departments performing below the university placement average (subquery)
SELECT t.dept_name, ROUND(t.placement_pct, 2) AS placement_pct
FROM (SELECT d.dept_name,
             100.0 * COUNT(DISTINCT o.student_id) / COUNT(DISTINCT s.student_id) AS placement_pct
      FROM department d
      JOIN student s    ON s.dept_id = d.dept_id
      LEFT JOIN offer o ON o.student_id = s.student_id
      GROUP BY d.dept_name) t
WHERE t.placement_pct < (SELECT 100.0 * COUNT(DISTINCT o2.student_id) / COUNT(DISTINCT s2.student_id)
                         FROM student s2
                         LEFT JOIN offer o2 ON o2.student_id = s2.student_id)
ORDER BY t.placement_pct;

-- Q5 Unplaced students
SELECT s.student_id, s.student_name, d.dept_name, s.cgpa
FROM student s
JOIN department d ON d.dept_id = s.dept_id
WHERE s.student_id NOT IN (SELECT o.student_id FROM offer o)
ORDER BY s.cgpa DESC;

-- Q6 Modification: CGPA corrected after revaluation
SELECT student_id, cgpa FROM student WHERE student_id = 'S307';
UPDATE student SET cgpa = 7.50 WHERE student_id = 'S307';
SELECT student_id, cgpa FROM student WHERE student_id = 'S307';
UPDATE student SET cgpa = 7.40 WHERE student_id = 'S307';

COMMIT;

-- ===================== COMPANIES & JOBS  (company, job_profile, eligibility_criteria, eligibility_dept) =====================
-- Q7 Job profiles with their eligibility rules
SELECT c.company_name, j.role_title, j.package_lpa, ec.min_cgpa, ec.max_backlogs,
       (SELECT COUNT(*) FROM eligibility_dept ed WHERE ed.criteria_id = ec.criteria_id) AS allowed_depts
FROM job_profile j
JOIN company c               ON c.company_id = j.company_id
JOIN eligibility_criteria ec ON ec.job_id = j.job_id
ORDER BY j.package_lpa DESC;

-- Q8 Eligible students for each company (and job)
SELECT c.company_name, j.role_title, s.student_id, s.student_name, s.cgpa
FROM job_profile j
JOIN company c               ON c.company_id = j.company_id
JOIN eligibility_criteria ec ON ec.job_id = j.job_id
JOIN eligibility_dept ed     ON ed.criteria_id = ec.criteria_id
JOIN student s               ON s.dept_id = ed.dept_id
WHERE s.cgpa >= ec.min_cgpa
  AND s.backlogs <= ec.max_backlogs
ORDER BY c.company_name, j.role_title, s.cgpa DESC;

-- Q9 Number of eligible students per company
SELECT c.company_name, COUNT(DISTINCT s.student_id) AS eligible_students
FROM job_profile j
JOIN company c               ON c.company_id = j.company_id
JOIN eligibility_criteria ec ON ec.job_id = j.job_id
JOIN eligibility_dept ed     ON ed.criteria_id = ec.criteria_id
JOIN student s               ON s.dept_id = ed.dept_id
WHERE s.cgpa >= ec.min_cgpa
  AND s.backlogs <= ec.max_backlogs
GROUP BY c.company_name
ORDER BY eligible_students DESC, c.company_name;

-- Q10 Recruitment success per company (offers made)
SELECT c.company_name, COUNT(o.offer_id) AS offers_made
FROM company c
JOIN job_profile j      ON j.company_id = c.company_id
LEFT JOIN application a ON a.job_id = j.job_id
LEFT JOIN offer o       ON o.application_id = a.application_id
GROUP BY c.company_name
ORDER BY offers_made DESC, c.company_name;

-- Q11 Companies with the highest recruitment success (most offers, subquery)
SELECT c.company_name, COUNT(o.offer_id) AS offers_made
FROM company c
JOIN job_profile j ON j.company_id = c.company_id
JOIN application a ON a.job_id = j.job_id
JOIN offer o       ON o.application_id = a.application_id
GROUP BY c.company_name
HAVING COUNT(o.offer_id) = (SELECT MAX(t.cnt)
                            FROM (SELECT COUNT(o2.offer_id) AS cnt
                                  FROM job_profile j2
                                  JOIN application a2 ON a2.job_id = j2.job_id
                                  JOIN offer o2       ON o2.application_id = a2.application_id
                                  GROUP BY j2.company_id) t);

-- Q12 Modification: Infosys raises the Systems Engineer minimum CGPA, then restores it
UPDATE eligibility_criteria SET min_cgpa = 6.50 WHERE job_id = 2;
SELECT job_id, min_cgpa FROM eligibility_criteria WHERE job_id = 2;
UPDATE eligibility_criteria SET min_cgpa = 6.00 WHERE job_id = 2;

-- Q13 Deletion with cascade: a job added by mistake is removed with its criteria and allowed departments
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (99, 3, 'Test Role', 5.00);
INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (99, 99, 6.00, 0);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (99, 1);
DELETE FROM job_profile WHERE job_id = 99;
SELECT (SELECT COUNT(*) FROM eligibility_criteria WHERE job_id = 99) AS criteria_left,
       (SELECT COUNT(*) FROM eligibility_dept WHERE criteria_id = 99) AS dept_rows_left
FROM company WHERE company_id = 1;

COMMIT;

-- ===================== DRIVES & APPLICATIONS  (placement_drive, application) =====================
-- Q14 Company-wise applications
SELECT c.company_name,
       COUNT(a.application_id) AS applications,
       SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) AS selected,
       SUM(CASE WHEN a.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected,
       SUM(CASE WHEN a.status = 'Applied'  THEN 1 ELSE 0 END) AS in_process
FROM company c
JOIN placement_drive pd ON pd.company_id = c.company_id
LEFT JOIN application a ON a.drive_id = pd.drive_id
GROUP BY c.company_name
ORDER BY applications DESC, c.company_name;

-- Q15 Placement-drive participation (students who took part in each drive)
SELECT pd.drive_id, c.company_name, pd.drive_date,
       COUNT(DISTINCT a.student_id) AS students_participated,
       COUNT(a.application_id)      AS applications,
       ROUND(100.0 * COUNT(DISTINCT a.student_id) / (SELECT COUNT(*) FROM student), 2) AS participation_pct
FROM placement_drive pd
JOIN company c          ON c.company_id = pd.company_id
LEFT JOIN application a ON a.drive_id = pd.drive_id
GROUP BY pd.drive_id, c.company_name, pd.drive_date
ORDER BY pd.drive_date;

-- Q16 Selection rate per company (selected / applications x 100)
SELECT c.company_name,
       COUNT(a.application_id) AS applications,
       SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) AS selected,
       ROUND(100.0 * SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) / COUNT(a.application_id), 2) AS selection_rate_pct
FROM company c
JOIN placement_drive pd ON pd.company_id = c.company_id
JOIN application a      ON a.drive_id = pd.drive_id
GROUP BY c.company_name
ORDER BY selection_rate_pct DESC;

-- Q17 Overall selection rate
SELECT COUNT(*) AS applications,
       SUM(CASE WHEN status = 'Selected' THEN 1 ELSE 0 END) AS selected,
       ROUND(100.0 * SUM(CASE WHEN status = 'Selected' THEN 1 ELSE 0 END) / COUNT(*), 2) AS overall_rate_pct
FROM application;

-- Q18 Companies with selection rate above the overall average (subquery)
SELECT c.company_name,
       ROUND(100.0 * SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) / COUNT(a.application_id), 2) AS selection_rate_pct
FROM company c
JOIN placement_drive pd ON pd.company_id = c.company_id
JOIN application a      ON a.drive_id = pd.drive_id
GROUP BY c.company_name
HAVING 100.0 * SUM(CASE WHEN a.status = 'Selected' THEN 1 ELSE 0 END) / COUNT(a.application_id)
     > (SELECT 100.0 * SUM(CASE WHEN status = 'Selected' THEN 1 ELSE 0 END) / COUNT(*) FROM application)
ORDER BY selection_rate_pct DESC;

-- Q19 Multi-table join: every application with student, company, job and drive
SELECT a.application_id, s.student_id, s.student_name, c.company_name, j.role_title, pd.drive_date, a.status
FROM application a
JOIN student s          ON s.student_id = a.student_id
JOIN job_profile j      ON j.job_id = a.job_id
JOIN placement_drive pd ON pd.drive_id = a.drive_id
JOIN company c          ON c.company_id = pd.company_id
ORDER BY a.application_id;

-- Q20 Modification: the pending TCS application is decided
SELECT application_id, status FROM application WHERE application_id = 21;
UPDATE application SET status = 'Rejected' WHERE application_id = 21;
SELECT application_id, status FROM application WHERE application_id = 21;
UPDATE application SET status = 'Applied' WHERE application_id = 21;

-- Q21 Deletion: a duplicate drive entered by mistake (no applications) is removed
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (99, 3, DATE '2026-12-01');
DELETE FROM placement_drive WHERE drive_id = 99;
SELECT COUNT(*) AS drives FROM placement_drive;

COMMIT;

-- ===================== SELECTION PROCESS & READINESS  (aptitude_test, interview) =====================
-- Q22 Aptitude results per drive (pass mark 60)
SELECT t.drive_id, t.student_id, t.score,
       CASE WHEN t.score >= 60 THEN 'Pass' ELSE 'Fail' END AS aptitude_result
FROM aptitude_test t
ORDER BY t.drive_id, t.score DESC;

-- Q23 Aptitude summary per drive
SELECT t.drive_id, COUNT(*) AS candidates, ROUND(AVG(t.score), 2) AS avg_score,
       SUM(CASE WHEN t.score >= 60 THEN 1 ELSE 0 END) AS passed
FROM aptitude_test t
GROUP BY t.drive_id
ORDER BY t.drive_id;

-- Q24 Interview rounds: pass/fail per round number
SELECT i.round_no,
       SUM(CASE WHEN i.result = 'Pass' THEN 1 ELSE 0 END) AS passed,
       SUM(CASE WHEN i.result = 'Fail' THEN 1 ELSE 0 END) AS failed
FROM interview i
GROUP BY i.round_no
ORDER BY i.round_no;

-- Q25 Interview success per student (rounds passed and success rate)
SELECT a.student_id,
       COUNT(i.interview_id) AS rounds_attended,
       SUM(CASE WHEN i.result = 'Pass' THEN 1 ELSE 0 END) AS rounds_passed,
       ROUND(100.0 * SUM(CASE WHEN i.result = 'Pass' THEN 1 ELSE 0 END) / COUNT(i.interview_id), 2) AS success_rate_pct
FROM interview i
JOIN application a ON a.application_id = i.application_id
GROUP BY a.student_id
ORDER BY rounds_passed DESC, a.student_id;

-- Q26 Readiness indicators for every student (database-derived)
SELECT s.student_id, d.dept_name AS department, s.cgpa,
       COALESCE((SELECT ROUND(AVG(t.score), 1) FROM aptitude_test t WHERE t.student_id = s.student_id), 0) AS aptitude_score,
       (SELECT COUNT(*) FROM interview i JOIN application a ON a.application_id = i.application_id
         WHERE a.student_id = s.student_id AND i.result = 'Pass') AS interview_success,
       (SELECT COUNT(*) FROM interview i JOIN application a ON a.application_id = i.application_id
         WHERE a.student_id = s.student_id) AS interview_rounds,
       (SELECT COUNT(*) FROM offer o WHERE o.student_id = s.student_id) AS offers
FROM student s
JOIN department d ON d.dept_id = s.dept_id
ORDER BY s.student_id;

-- Q27 Readiness classification (weighted score + CASE)
SELECT student_id, department, cgpa, aptitude_score, interview_success, offers,
       ROUND(0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100), 1) AS readiness_score,
       CASE
           WHEN cgpa < 6.0 OR aptitude_score < 40 THEN 'NEEDS INTERVENTION'
           WHEN (0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100)) >= 75 THEN 'PLACEMENT READY'
           WHEN (0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100)) >= 60 THEN 'MODERATELY READY'
           WHEN (0.35 * (cgpa * 10) + 0.35 * aptitude_score + 0.15 * (LEAST(interview_success, 4) * 25) + 0.15 * (LEAST(offers, 1) * 100)) >= 45 THEN 'NEEDS TRAINING'
           ELSE 'NEEDS INTERVENTION'
       END AS readiness
FROM (SELECT s.student_id, d.dept_name AS department, s.cgpa,
       COALESCE((SELECT ROUND(AVG(t.score), 1) FROM aptitude_test t WHERE t.student_id = s.student_id), 0) AS aptitude_score,
       (SELECT COUNT(*) FROM interview i JOIN application a ON a.application_id = i.application_id
         WHERE a.student_id = s.student_id AND i.result = 'Pass') AS interview_success,
       (SELECT COUNT(*) FROM interview i JOIN application a ON a.application_id = i.application_id
         WHERE a.student_id = s.student_id) AS interview_rounds,
       (SELECT COUNT(*) FROM offer o WHERE o.student_id = s.student_id) AS offers
FROM student s
JOIN department d ON d.dept_id = s.dept_id) ind
ORDER BY readiness_score DESC;

-- Q28 Modification: a pending interview round is recorded, updated, then removed
INSERT INTO interview (interview_id, application_id, round_no) VALUES (99, 21, 1);
SELECT interview_id, application_id, round_no, result FROM interview WHERE interview_id = 99;
UPDATE interview SET result = 'Pass' WHERE interview_id = 99;
SELECT interview_id, application_id, round_no, result FROM interview WHERE interview_id = 99;
DELETE FROM interview WHERE interview_id = 99;

COMMIT;

-- ===================== OFFERS & JOINING  (offer, joining_status) =====================
-- Q29 Average package (overall)
SELECT COUNT(*) AS total_offers, ROUND(AVG(package_lpa), 2) AS avg_package_lpa
FROM offer;

-- Q30 Average package per company
SELECT c.company_name, COUNT(o.offer_id) AS offers, ROUND(AVG(o.package_lpa), 2) AS avg_package_lpa
FROM offer o
JOIN application a ON a.application_id = o.application_id
JOIN job_profile j ON j.job_id = a.job_id
JOIN company c     ON c.company_id = j.company_id
GROUP BY c.company_name
ORDER BY avg_package_lpa DESC;

-- Q31 Average package per department
SELECT d.dept_name, COUNT(o.offer_id) AS offers, ROUND(AVG(o.package_lpa), 2) AS avg_package_lpa
FROM offer o
JOIN student s    ON s.student_id = o.student_id
JOIN department d ON d.dept_id = s.dept_id
GROUP BY d.dept_name
ORDER BY avg_package_lpa DESC;

-- Q32 Highest and lowest package
SELECT MAX(package_lpa) AS highest_package_lpa, MIN(package_lpa) AS lowest_package_lpa
FROM offer;

-- Q33 Who received the highest and lowest packages
SELECT 'Highest' AS package_type, s.student_id, s.student_name, c.company_name, o.package_lpa
FROM offer o
JOIN student s     ON s.student_id = o.student_id
JOIN application a ON a.application_id = o.application_id
JOIN job_profile j ON j.job_id = a.job_id
JOIN company c     ON c.company_id = j.company_id
WHERE o.package_lpa = (SELECT MAX(package_lpa) FROM offer)
UNION ALL
SELECT 'Lowest', s.student_id, s.student_name, c.company_name, o.package_lpa
FROM offer o
JOIN student s     ON s.student_id = o.student_id
JOIN application a ON a.application_id = o.application_id
JOIN job_profile j ON j.job_id = a.job_id
JOIN company c     ON c.company_id = j.company_id
WHERE o.package_lpa = (SELECT MIN(package_lpa) FROM offer)
ORDER BY package_type, student_id;

-- Q34 Students receiving multiple offers
SELECT s.student_id, s.student_name, COUNT(o.offer_id) AS offers, MAX(o.package_lpa) AS best_package_lpa
FROM offer o
JOIN student s ON s.student_id = o.student_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(o.offer_id) > 1
ORDER BY offers DESC, best_package_lpa DESC, s.student_id;

-- Q35 Students selected at a package above their department average (correlated subquery)
SELECT s.student_id, s.student_name, d.dept_name, o.package_lpa,
       (SELECT ROUND(AVG(o2.package_lpa), 2)
          FROM offer o2
          JOIN student s2 ON s2.student_id = o2.student_id
         WHERE s2.dept_id = s.dept_id) AS dept_avg_lpa
FROM offer o
JOIN student s    ON s.student_id = o.student_id
JOIN department d ON d.dept_id = s.dept_id
WHERE o.package_lpa > (SELECT AVG(o2.package_lpa)
                         FROM offer o2
                         JOIN student s2 ON s2.student_id = o2.student_id
                        WHERE s2.dept_id = s.dept_id)
ORDER BY d.dept_name, o.package_lpa DESC, s.student_id;

-- Q36 Joining status summary
SELECT js.status, COUNT(*) AS offers, ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM joining_status), 2) AS pct
FROM joining_status js
GROUP BY js.status
ORDER BY offers DESC;

-- Q37 Modification: S306 joins TCS, S302 declines
SELECT joining_id, offer_id, status FROM joining_status WHERE offer_id IN (8, 11);
UPDATE joining_status SET status = 'Joined'   WHERE offer_id = 8;
UPDATE joining_status SET status = 'Declined' WHERE offer_id = 11;
SELECT joining_id, offer_id, status FROM joining_status WHERE offer_id IN (8, 11);

-- Q38 Modification: Zoho revises its package from 11.00 to 12.00 LPA
UPDATE offer SET package_lpa = 12.00
WHERE application_id IN (SELECT a.application_id
                           FROM application a
                           JOIN job_profile j ON j.job_id = a.job_id
                          WHERE j.company_id = 3);
SELECT offer_id, student_id, package_lpa FROM offer WHERE package_lpa = 12.00;

-- Q39 Deletion with cascade: a wrongly issued offer is removed, its joining record goes with it
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (14, 17, 'S302', 6.50, DATE '2025-08-18');
INSERT INTO joining_status (joining_id, offer_id) VALUES (14, 14);
SELECT o.offer_id, js.joining_id, js.status FROM offer o JOIN joining_status js ON js.offer_id = o.offer_id WHERE o.offer_id = 14;
DELETE FROM offer WHERE offer_id = 14;
SELECT COUNT(*) AS joining_rows_left_for_offer_14 FROM joining_status WHERE offer_id = 14;

COMMIT;

