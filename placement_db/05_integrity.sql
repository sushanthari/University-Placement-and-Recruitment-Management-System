-- 05_integrity.sql  statements that are SUPPOSED to fail, proving the constraints work

-- ===================== STUDENTS & ACADEMICS  (department, program, student) =====================
-- I1 FK: student in a department that does not exist
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S999', 9, 101, 'Test Student', 7.00, 0, 2026);

-- I2 Composite FK: CSE program (101) with ECE department (2) does not match
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S998', 2, 101, 'Test Student', 7.00, 0, 2026);

-- I3 CHECK: CGPA above 10
UPDATE student SET cgpa = 11.00 WHERE student_id = 'S101';

-- I4 UNIQUE: duplicate department name
INSERT INTO department (dept_id, dept_name) VALUES (9, 'CSE');

-- I5 PRIMARY KEY: duplicate student id
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S101', 1, 101, 'Duplicate', 7.00, 0, 2026);

-- I6 NOT NULL: student without a name
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S997', 1, 101, NULL, 7.00, 0, 2026);

-- I7 FK restrict: cannot delete a department that still has programs and students
DELETE FROM department WHERE dept_id = 1;

-- ===================== COMPANIES & JOBS  (company, job_profile, eligibility_criteria, eligibility_dept) =====================
-- I8 FK: job for a company that does not exist
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (90, 99, 'Analyst', 5.00);

-- I9 CHECK: negative package
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (91, 1, 'Analyst', -5.00);

-- I10 CHECK: minimum CGPA above 10
UPDATE eligibility_criteria SET min_cgpa = 12.00 WHERE criteria_id = 1;

-- I11 UNIQUE: duplicate company name
INSERT INTO company (company_id, company_name) VALUES (9, 'TCS');

-- I12 UNIQUE: second criteria row for the same job
INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (90, 1, 7.00, 0);

-- I13 Composite PRIMARY KEY: the same department allowed twice for one criteria
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (1, 1);

-- I14 FK restrict: cannot delete a company that still has job profiles
DELETE FROM company WHERE company_id = 1;

-- ===================== DRIVES & APPLICATIONS  (placement_drive, application) =====================
-- I15 FK: application by a student who does not exist
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (90, 'S999', 1, 1, 'Applied');

-- I16 FK: application to a drive that does not exist
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (91, 'S101', 1, 99, 'Applied');

-- I17 UNIQUE: same student, job and drive twice
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (92, 'S301', 3, 3, 'Applied');

-- I18 CHECK: status spelling outside the contract
UPDATE application SET status = 'Accepted' WHERE application_id = 1;

-- I19 FK: drive for a company that does not exist
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (90, 99, DATE '2026-01-10');

-- I20 FK restrict: cannot delete a drive that has applications
DELETE FROM placement_drive WHERE drive_id = 1;

-- Business-rule check (must return 0 rows): the job's company must be the drive's company
SELECT a.application_id, j.company_id AS job_company, pd.company_id AS drive_company
FROM application a
JOIN job_profile j      ON j.job_id = a.job_id
JOIN placement_drive pd ON pd.drive_id = a.drive_id
WHERE j.company_id <> pd.company_id;

-- ===================== SELECTION PROCESS & READINESS  (aptitude_test, interview) =====================
-- I21 FK: aptitude test for a student who does not exist
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (90, 'S999', 1, 70);

-- I22 UNIQUE: second aptitude test for the same student in the same drive
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (91, 'S101', 1, 70);

-- I23 CHECK: score above 100
UPDATE aptitude_test SET score = 120 WHERE test_id = 1;

-- I24 FK: interview for an application that does not exist
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (90, 999, 1, 'Pass');

-- I25 UNIQUE: the same round recorded twice
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (91, 3, 1, 'Pass');

-- I26 CHECK: result spelling outside the contract
UPDATE interview SET result = 'Cleared' WHERE interview_id = 1;

-- I27 FK restrict: cannot delete a drive that has aptitude tests
DELETE FROM placement_drive WHERE drive_id = 3;

-- ===================== OFFERS & JOINING  (offer, joining_status) =====================
-- I28 FK: offer for an application that does not exist
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (90, 999, 'S101', 5.00, DATE '2025-09-01');

-- I29 FK: joining record for an offer that does not exist
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (90, 999, 'Joined');

-- I30 UNIQUE: second offer on the same application
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (91, 3, 'S301', 11.00, DATE '2025-10-25');

-- I31 CHECK: package must be positive
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (92, 1, 'S101', -3.00, DATE '2025-09-01');

-- I32 CHECK: status spelling outside the contract
UPDATE joining_status SET status = 'Accepted' WHERE joining_id = 1;

-- I33 NOT NULL: offer without a date
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (93, 2, 'S101', 4.00, NULL);

-- I34 FK restrict: cannot delete a student who holds offers
DELETE FROM student WHERE student_id = 'S301';

-- Business-rule checks: each query must return 0 rows
SELECT o.offer_id, o.student_id, a.student_id AS application_student
FROM offer o JOIN application a ON a.application_id = o.application_id
WHERE o.student_id <> a.student_id;

SELECT o.offer_id, a.status
FROM offer o JOIN application a ON a.application_id = o.application_id
WHERE a.status <> 'Selected';

SELECT o.student_id, COUNT(*) AS joined_count
FROM offer o JOIN joining_status js ON js.offer_id = o.offer_id
WHERE js.status = 'Joined'
GROUP BY o.student_id
HAVING COUNT(*) > 1;

