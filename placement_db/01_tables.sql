-- 01_tables.sql  creates all 13 tables with their constraints (parents before children)

-- ===================== STUDENTS & ACADEMICS  (department, program, student) =====================
CREATE TABLE department (
    dept_id     INT          PRIMARY KEY,
    dept_name   VARCHAR(50)  NOT NULL,
    CONSTRAINT uq_department_name UNIQUE (dept_name)
);

CREATE TABLE program (
    program_id    INT           PRIMARY KEY,
    dept_id       INT           NOT NULL,
    program_name  VARCHAR(60)   NOT NULL,
    CONSTRAINT uq_program_name      UNIQUE (program_name),
    CONSTRAINT uq_program_dept      UNIQUE (program_id, dept_id),
    CONSTRAINT fk_program_dept      FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE student (
    student_id    VARCHAR(10)   PRIMARY KEY,
    dept_id       INT           NOT NULL,
    program_id    INT           NOT NULL,
    student_name  VARCHAR(50)   NOT NULL,
    cgpa          DECIMAL(4,2)  NOT NULL,
    backlogs      INT           DEFAULT 0 NOT NULL,
    batch_year    INT           NOT NULL,
    CONSTRAINT ck_student_cgpa     CHECK (cgpa BETWEEN 0 AND 10),
    CONSTRAINT ck_student_backlogs CHECK (backlogs >= 0),
    CONSTRAINT ck_student_batch    CHECK (batch_year BETWEEN 2000 AND 2100),
    CONSTRAINT fk_student_dept     FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    CONSTRAINT fk_student_program  FOREIGN KEY (program_id, dept_id) REFERENCES program(program_id, dept_id)
);

-- ===================== COMPANIES & JOBS  (company, job_profile, eligibility_criteria, eligibility_dept) =====================
CREATE TABLE company (
    company_id    INT          PRIMARY KEY,
    company_name  VARCHAR(50)  NOT NULL,
    CONSTRAINT uq_company_name UNIQUE (company_name)
);

CREATE TABLE job_profile (
    job_id        INT           PRIMARY KEY,
    company_id    INT           NOT NULL,
    role_title    VARCHAR(50)   NOT NULL,
    package_lpa   DECIMAL(5,2)  NOT NULL,
    CONSTRAINT fk_job_company FOREIGN KEY (company_id) REFERENCES company(company_id),
    CONSTRAINT ck_job_package      CHECK (package_lpa > 0 AND package_lpa <= 100)
);

CREATE TABLE eligibility_criteria (
    criteria_id   INT           PRIMARY KEY,
    job_id        INT           NOT NULL,
    min_cgpa      DECIMAL(4,2)  DEFAULT 0 NOT NULL,
    max_backlogs  INT           DEFAULT 0 NOT NULL,
    CONSTRAINT uq_criteria_job     UNIQUE (job_id),
    CONSTRAINT ck_criteria_cgpa    CHECK (min_cgpa BETWEEN 0 AND 10),
    CONSTRAINT ck_criteria_backlog CHECK (max_backlogs >= 0),
    CONSTRAINT fk_criteria_job     FOREIGN KEY (job_id) REFERENCES job_profile(job_id) ON DELETE CASCADE
);

CREATE TABLE eligibility_dept (
    criteria_id   INT  NOT NULL,
    dept_id       INT  NOT NULL,
    CONSTRAINT pk_eligibility_dept PRIMARY KEY (criteria_id, dept_id),
    CONSTRAINT fk_eligdept_criteria FOREIGN KEY (criteria_id) REFERENCES eligibility_criteria(criteria_id) ON DELETE CASCADE,
    CONSTRAINT fk_eligdept_dept     FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- ===================== DRIVES & APPLICATIONS  (placement_drive, application) =====================
CREATE TABLE placement_drive (
    drive_id     INT   PRIMARY KEY,
    company_id   INT   NOT NULL,
    drive_date   DATE  NOT NULL,
    CONSTRAINT uq_drive_company_date UNIQUE (company_id, drive_date),
    CONSTRAINT fk_drive_company      FOREIGN KEY (company_id) REFERENCES company(company_id)
);

CREATE TABLE application (
    application_id  INT           PRIMARY KEY,
    student_id      VARCHAR(10)   NOT NULL,
    job_id          INT           NOT NULL,
    drive_id        INT           NOT NULL,
    status          VARCHAR(10)   DEFAULT 'Applied' NOT NULL,
    CONSTRAINT uq_application_once  UNIQUE (student_id, job_id, drive_id),
    CONSTRAINT ck_application_status CHECK (status IN ('Applied', 'Selected', 'Rejected')),
    CONSTRAINT fk_application_student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT fk_application_job     FOREIGN KEY (job_id) REFERENCES job_profile(job_id),
    CONSTRAINT fk_application_drive   FOREIGN KEY (drive_id) REFERENCES placement_drive(drive_id)
);

-- ===================== SELECTION PROCESS & READINESS  (aptitude_test, interview) =====================
CREATE TABLE aptitude_test (
    test_id      INT           PRIMARY KEY,
    student_id   VARCHAR(10)   NOT NULL,
    drive_id     INT           NOT NULL,
    score        INT           NOT NULL,
    CONSTRAINT uq_aptitude_once    UNIQUE (student_id, drive_id),
    CONSTRAINT ck_aptitude_score   CHECK (score BETWEEN 0 AND 100),
    CONSTRAINT fk_aptitude_student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT fk_aptitude_drive   FOREIGN KEY (drive_id) REFERENCES placement_drive(drive_id)
);

CREATE TABLE interview (
    interview_id    INT           PRIMARY KEY,
    application_id  INT           NOT NULL,
    round_no        INT           NOT NULL,
    result          VARCHAR(10)   DEFAULT 'Pending' NOT NULL,
    CONSTRAINT uq_interview_round      UNIQUE (application_id, round_no),
    CONSTRAINT ck_interview_round      CHECK (round_no BETWEEN 1 AND 5),
    CONSTRAINT ck_interview_result     CHECK (result IN ('Pass', 'Fail', 'Pending')),
    CONSTRAINT fk_interview_application FOREIGN KEY (application_id) REFERENCES application(application_id) ON DELETE CASCADE
);

-- ===================== OFFERS & JOINING  (offer, joining_status) =====================
CREATE TABLE offer (
    offer_id        INT           PRIMARY KEY,
    application_id  INT           NOT NULL,
    student_id      VARCHAR(10)   NOT NULL,
    package_lpa     DECIMAL(5,2)  NOT NULL,
    offer_date      DATE          NOT NULL,
    CONSTRAINT uq_offer_application UNIQUE (application_id),
    CONSTRAINT ck_offer_package     CHECK (package_lpa > 0 AND package_lpa <= 100),
    CONSTRAINT fk_offer_application FOREIGN KEY (application_id) REFERENCES application(application_id) ON DELETE CASCADE,
    CONSTRAINT fk_offer_student     FOREIGN KEY (student_id) REFERENCES student(student_id)
);

CREATE TABLE joining_status (
    joining_id      INT           PRIMARY KEY,
    offer_id        INT           NOT NULL,
    status          VARCHAR(10)   DEFAULT 'Pending' NOT NULL,
    CONSTRAINT uq_joining_offer  UNIQUE (offer_id),
    CONSTRAINT ck_joining_status CHECK (status IN ('Joined', 'Pending', 'Declined')),
    CONSTRAINT fk_joining_offer  FOREIGN KEY (offer_id) REFERENCES offer(offer_id) ON DELETE CASCADE
);

