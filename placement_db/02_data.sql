-- 02_data.sql  inserts the sample data (same order as the tables)

-- ===================== STUDENTS & ACADEMICS  (department, program, student) =====================
INSERT INTO department (dept_id, dept_name) VALUES (1, 'CSE');
INSERT INTO department (dept_id, dept_name) VALUES (2, 'ECE');
INSERT INTO department (dept_id, dept_name) VALUES (3, 'MECH');

INSERT INTO program (program_id, dept_id, program_name) VALUES (101, 1, 'B.Tech Computer Science and Engineering');
INSERT INTO program (program_id, dept_id, program_name) VALUES (102, 2, 'B.Tech Electronics and Communication Engineering');
INSERT INTO program (program_id, dept_id, program_name) VALUES (103, 3, 'B.Tech Mechanical Engineering');
INSERT INTO program (program_id, dept_id, program_name) VALUES (104, 1, 'M.Tech Computer Science and Engineering');

INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S101', 1, 101, 'Arjun Menon', 6.40, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S301', 1, 101, 'Priya Raman', 9.10, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S303', 1, 101, 'Karthik Iyer', 8.20, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S307', 1, 101, 'Sneha Pillai', 7.40, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S205', 2, 102, 'Aditya Varma', 8.60, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S304', 2, 102, 'Divya Krishnan', 7.80, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S306', 2, 102, 'Vikram Rao', 6.90, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S302', 3, 103, 'Naveen Kumar', 6.60, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S305', 3, 103, 'Lakshmi Prasad', 7.20, 0, 2026);
INSERT INTO student (student_id, dept_id, program_id, student_name, cgpa, backlogs, batch_year) VALUES ('S308', 3, 103, 'Ganesh Murthy', 7.60, 0, 2026);

COMMIT;

-- ===================== COMPANIES & JOBS  (company, job_profile, eligibility_criteria, eligibility_dept) =====================
INSERT INTO company (company_id, company_name) VALUES (1, 'TCS');
INSERT INTO company (company_id, company_name) VALUES (2, 'Infosys');
INSERT INTO company (company_id, company_name) VALUES (3, 'Zoho');
INSERT INTO company (company_id, company_name) VALUES (4, 'L&T');

INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (1, 1, 'Ninja Developer', 4.00);
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (2, 2, 'Systems Engineer', 6.50);
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (3, 3, 'Member Technical Staff', 11.00);
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (4, 1, 'Digital Developer', 7.50);
INSERT INTO job_profile (job_id, company_id, role_title, package_lpa) VALUES (5, 4, 'Graduate Engineer Trainee', 7.00);

INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (1, 1, 6.00, 1);
INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (2, 2, 6.00, 0);
INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (3, 3, 7.00, 0);
INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (4, 4, 7.00, 0);
INSERT INTO eligibility_criteria (criteria_id, job_id, min_cgpa, max_backlogs) VALUES (5, 5, 6.50, 0);

INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (1, 1);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (1, 2);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (1, 3);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (2, 1);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (2, 2);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (2, 3);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (3, 1);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (3, 2);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (4, 1);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (4, 2);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (4, 3);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (5, 2);
INSERT INTO eligibility_dept (criteria_id, dept_id) VALUES (5, 3);

COMMIT;

-- ===================== DRIVES & APPLICATIONS  (placement_drive, application) =====================
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (1, 1, DATE '2025-09-03');
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (2, 2, DATE '2025-08-12');
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (3, 3, DATE '2025-10-22');
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (4, 4, DATE '2025-10-06');
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (5, 2, DATE '2026-08-11');
INSERT INTO placement_drive (drive_id, company_id, drive_date) VALUES (6, 1, DATE '2026-09-02');

INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (1, 'S101', 2, 2, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (2, 'S101', 1, 1, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (3, 'S301', 3, 3, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (4, 'S301', 2, 2, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (5, 'S303', 3, 3, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (6, 'S303', 4, 1, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (7, 'S307', 2, 2, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (8, 'S304', 3, 3, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (9, 'S304', 2, 2, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (10, 'S306', 1, 1, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (11, 'S205', 3, 3, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (12, 'S205', 4, 1, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (13, 'S305', 2, 2, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (14, 'S302', 1, 1, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (15, 'S308', 4, 1, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (16, 'S308', 1, 1, 'Selected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (17, 'S302', 2, 2, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (18, 'S305', 5, 4, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (19, 'S306', 5, 4, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (20, 'S308', 5, 4, 'Rejected');
INSERT INTO application (application_id, student_id, job_id, drive_id, status) VALUES (21, 'S307', 4, 1, 'Applied');

COMMIT;

-- ===================== SELECTION PROCESS & READINESS  (aptitude_test, interview) =====================
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (1, 'S101', 2, 50);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (2, 'S101', 1, 46);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (3, 'S301', 3, 92);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (4, 'S301', 2, 85);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (5, 'S303', 3, 81);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (6, 'S303', 1, 80);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (7, 'S307', 2, 72);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (8, 'S304', 3, 77);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (9, 'S304', 2, 74);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (10, 'S306', 1, 63);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (11, 'S306', 4, 55);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (12, 'S205', 1, 84);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (13, 'S205', 3, 88);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (14, 'S305', 2, 70);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (15, 'S305', 4, 68);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (16, 'S302', 1, 61);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (17, 'S302', 2, 58);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (18, 'S308', 1, 74);
INSERT INTO aptitude_test (test_id, student_id, drive_id, score) VALUES (19, 'S308', 4, 66);

INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (1, 3, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (2, 3, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (3, 4, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (4, 4, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (5, 5, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (6, 5, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (7, 6, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (8, 6, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (9, 7, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (10, 7, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (11, 8, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (12, 8, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (13, 9, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (14, 9, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (15, 10, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (16, 10, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (17, 11, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (18, 11, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (19, 12, 1, 'Fail');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (20, 13, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (21, 13, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (22, 14, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (23, 14, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (24, 15, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (25, 15, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (26, 16, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (27, 16, 2, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (28, 18, 1, 'Pass');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (29, 18, 2, 'Fail');
INSERT INTO interview (interview_id, application_id, round_no, result) VALUES (30, 20, 1, 'Fail');

COMMIT;

-- ===================== OFFERS & JOINING  (offer, joining_status) =====================
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (1, 3, 'S301', 11.00, DATE '2025-10-24');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (2, 4, 'S301', 6.50, DATE '2025-08-18');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (3, 5, 'S303', 11.00, DATE '2025-10-24');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (4, 6, 'S303', 7.50, DATE '2025-09-08');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (5, 7, 'S307', 6.50, DATE '2025-08-18');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (6, 8, 'S304', 11.00, DATE '2025-10-24');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (7, 9, 'S304', 6.50, DATE '2025-08-18');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (8, 10, 'S306', 4.00, DATE '2025-09-08');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (9, 11, 'S205', 11.00, DATE '2025-10-24');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (10, 13, 'S305', 6.50, DATE '2025-08-18');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (11, 14, 'S302', 4.00, DATE '2025-09-08');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (12, 15, 'S308', 7.50, DATE '2025-09-08');
INSERT INTO offer (offer_id, application_id, student_id, package_lpa, offer_date) VALUES (13, 16, 'S308', 4.00, DATE '2025-09-08');

INSERT INTO joining_status (joining_id, offer_id, status) VALUES (1, 1, 'Joined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (2, 2, 'Declined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (3, 3, 'Joined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (4, 4, 'Declined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (5, 5, 'Joined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (6, 6, 'Joined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (7, 7, 'Declined');
INSERT INTO joining_status (joining_id, offer_id) VALUES (8, 8);
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (9, 9, 'Joined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (10, 10, 'Joined');
INSERT INTO joining_status (joining_id, offer_id) VALUES (11, 11);
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (12, 12, 'Joined');
INSERT INTO joining_status (joining_id, offer_id, status) VALUES (13, 13, 'Declined');

COMMIT;

