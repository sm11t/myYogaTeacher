-- backend/db_seed.sql

-- 0. Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Cleanup old tables (drop in child‐first order)
DROP TABLE IF EXISTS student_concierge CASCADE;
DROP TABLE IF EXISTS session            CASCADE;
DROP TABLE IF EXISTS membership         CASCADE;
DROP TABLE IF EXISTS transaction        CASCADE;
DROP TABLE IF EXISTS teacher            CASCADE;
DROP TABLE IF EXISTS student            CASCADE;

-- 2. STUDENT
CREATE TABLE student (
  id                          SERIAL        PRIMARY KEY,
  uuid                        VARCHAR(100)  NOT NULL UNIQUE,
  created_date                TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_date               TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  first_name                  VARCHAR(100)  DEFAULT '',
  middle_name                 VARCHAR(100)  DEFAULT '',
  last_name                   VARCHAR(100)  DEFAULT '',
  email                       VARCHAR(255),
  phone_personal              VARCHAR(45)   DEFAULT '',
  gender                      VARCHAR(50),
  credits                     FLOAT         DEFAULT 0,
  credits_currency            VARCHAR(45)   DEFAULT 'USD',
  is_credits_currency_fixed   SMALLINT      NOT NULL DEFAULT 0,
  password                    VARCHAR(100),
  iana_timezone               VARCHAR(255)  DEFAULT '',
  funnel_url                  VARCHAR(1000) DEFAULT '',
  funnel_type                 VARCHAR(255)  NOT NULL DEFAULT '',
  trial_start_date            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  trial_end_date              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. TEACHER
CREATE TABLE teacher (
  id                              SERIAL        PRIMARY KEY,
  uuid                            VARCHAR(100)  NOT NULL UNIQUE,
  status                          VARCHAR(50)   NOT NULL DEFAULT 'INTERESTED_TO_JOIN',
  created_date                    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
  modified_date                   TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
  first_name                      VARCHAR(45)   DEFAULT '',
  middle_name                     VARCHAR(45)   DEFAULT '',
  last_name                       VARCHAR(45)   DEFAULT '',
  last_name_full_value            VARCHAR(45)   DEFAULT '',
  email                           VARCHAR(255),
  phone_personal                  VARCHAR(45),
  gender                          VARCHAR(6),
  profile_photo                   VARCHAR(500)  NOT NULL DEFAULT '',
  goals                           TEXT,
  years_of_yoga_practise          INT           DEFAULT 0,
  years_of_yoga_teaching_experience INT         DEFAULT 0,
  video_thumbnail                 VARCHAR(255)  DEFAULT '',
  iana_timezone                   VARCHAR(255)  DEFAULT '',
  slug                            VARCHAR(100)  NOT NULL DEFAULT ''
);

-- 4. STUDENT_CONCIERGE
-- Add UNIQUE(student_id) so that ON CONFLICT(student_id) is valid
CREATE TABLE student_concierge (
  id            SERIAL      PRIMARY KEY,
  student_id    INT         NOT NULL REFERENCES student(id),
  teacher_id    INT         NOT NULL REFERENCES teacher(id),
  created_date  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_date TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (student_id)
);

-- 5. SESSION
CREATE TABLE session (
  id               SERIAL        PRIMARY KEY,
  uuid             VARCHAR(100)  NOT NULL UNIQUE,
  student_uuid     VARCHAR(100)  NOT NULL REFERENCES student(uuid),
  teacher_uuid     VARCHAR(100)  NOT NULL REFERENCES teacher(uuid),
  start_time       TIMESTAMP,
  end_time         TIMESTAMP,
  duration         INT           DEFAULT 60,
  status           VARCHAR(32),
  is_trial         INT           DEFAULT 0,
  is_first_session BOOLEAN       NOT NULL DEFAULT FALSE,
  student_joined   INT           DEFAULT 0,
  teacher_joined   INT           DEFAULT 0,
  created_date     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  modified_date    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  student_id       INT           NOT NULL REFERENCES student(id),
  teacher_id       INT           NOT NULL REFERENCES teacher(id),
  type             VARCHAR(16)
);

-- 6. TRANSACTION
-- Add UNIQUE(order_id) so that ON CONFLICT(order_id) is valid
CREATE TABLE transaction (
  id                  SERIAL        PRIMARY KEY,
  student_uuid        VARCHAR(100)  REFERENCES student(uuid),
  package_id          INT,
  currency            VARCHAR(3),
  type                VARCHAR(20)   NOT NULL DEFAULT 'PAY_PER_USE',
  recurring           INT           DEFAULT 0,
  order_id            VARCHAR(45)   UNIQUE DEFAULT '',
  next_billing_date   TIMESTAMP,
  subscription_status VARCHAR(16),
  purchase_date       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  user_agent          VARCHAR(1000) DEFAULT '',
  created_date        TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  modified_date       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  student_id          INT           REFERENCES student(id)
);

-- 7. MEMBERSHIP
-- Add UNIQUE(student_id) so that ON CONFLICT(student_id) is valid
CREATE TABLE membership (
  id                SERIAL        PRIMARY KEY,
  student_id        INT           NOT NULL REFERENCES student(id) UNIQUE,
  start_date        TIMESTAMP     NOT NULL,
  end_date          TIMESTAMP     NOT NULL,
  is_active         BOOLEAN       NOT NULL DEFAULT TRUE,
  next_renewal_date TIMESTAMP,
  created_date      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  modified_date     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);


-- 8. Seed STUDENT (40 rows)
INSERT INTO student
  (uuid, first_name, middle_name, last_name, email, phone_personal, gender,
   credits, credits_currency, is_credits_currency_fixed, password, iana_timezone,
   funnel_url, funnel_type, trial_start_date, trial_end_date)
VALUES
  -- Row  1
  (gen_random_uuid()::text, 'First1','', 'Last1',  'user1@example.com','555-0001','MALE',
   2.5, 'USD', 1, 'pwd1','UTC','', '', NOW() - INTERVAL '1 days',  NOW() + INTERVAL '29 days'),
  -- Row  2
  (gen_random_uuid()::text, 'First2','', 'Last2',  'user2@example.com','555-0002','FEMALE',
   5.0, 'USD', 0, 'pwd2','UTC','', '', NOW() - INTERVAL '2 days',  NOW() + INTERVAL '28 days'),
  -- Row  3
  (gen_random_uuid()::text, 'First3','', 'Last3',  'user3@example.com','555-0003','MALE',
   7.5, 'USD', 1, 'pwd3','UTC','', '', NOW() - INTERVAL '3 days',  NOW() + INTERVAL '27 days'),
  -- Row  4
  (gen_random_uuid()::text, 'First4','', 'Last4',  'user4@example.com','555-0004','FEMALE',
   10.0, 'USD',0, 'pwd4','UTC','', '', NOW() - INTERVAL '4 days',  NOW() + INTERVAL '26 days'),
  -- Row  5
  (gen_random_uuid()::text, 'First5','', 'Last5',  'user5@example.com','555-0005','MALE',
   12.5, 'USD',1, 'pwd5','UTC','', '', NOW() - INTERVAL '5 days',  NOW() + INTERVAL '25 days'),
  -- Row  6
  (gen_random_uuid()::text, 'First6','', 'Last6',  'user6@example.com','555-0006','FEMALE',
   15.0, 'USD',0, 'pwd6','UTC','', '', NOW() - INTERVAL '6 days',  NOW() + INTERVAL '24 days'),
  -- Row  7
  (gen_random_uuid()::text, 'First7','', 'Last7',  'user7@example.com','555-0007','MALE',
   17.5, 'USD',1, 'pwd7','UTC','', '', NOW() - INTERVAL '7 days',  NOW() + INTERVAL '23 days'),
  -- Row  8
  (gen_random_uuid()::text, 'First8','', 'Last8',  'user8@example.com','555-0008','FEMALE',
   20.0, 'USD',0, 'pwd8','UTC','', '', NOW() - INTERVAL '8 days',  NOW() + INTERVAL '22 days'),
  -- Row  9
  (gen_random_uuid()::text, 'First9','', 'Last9',  'user9@example.com','555-0009','MALE',
   22.5, 'USD',1, 'pwd9','UTC','', '', NOW() - INTERVAL '9 days',  NOW() + INTERVAL '21 days'),
  -- Row 10
  (gen_random_uuid()::text, 'First10','', 'Last10','user10@example.com','555-0010','FEMALE',
   25.0,'USD',0,'pwd10','UTC','', '', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
  -- Row 11
  (gen_random_uuid()::text, 'First11','', 'Last11','user11@example.com','555-0011','MALE',
   27.5,'USD',1,'pwd11','UTC','', '', NOW() - INTERVAL '11 days', NOW() + INTERVAL '19 days'),
  -- Row 12
  (gen_random_uuid()::text, 'First12','', 'Last12','user12@example.com','555-0012','FEMALE',
   30.0,'USD',0,'pwd12','UTC','', '', NOW() - INTERVAL '12 days', NOW() + INTERVAL '18 days'),
  -- Row 13
  (gen_random_uuid()::text, 'First13','', 'Last13','user13@example.com','555-0013','MALE',
   32.5,'USD',1,'pwd13','UTC','', '', NOW() - INTERVAL '13 days', NOW() + INTERVAL '17 days'),
  -- Row 14
  (gen_random_uuid()::text, 'First14','', 'Last14','user14@example.com','555-0014','FEMALE',
   35.0,'USD',0,'pwd14','UTC','', '', NOW() - INTERVAL '14 days', NOW() + INTERVAL '16 days'),
  -- Row 15
  (gen_random_uuid()::text, 'First15','', 'Last15','user15@example.com','555-0015','MALE',
   37.5,'USD',1,'pwd15','UTC','', '', NOW() - INTERVAL '15 days', NOW() + INTERVAL '15 days'),
  -- Row 16
  (gen_random_uuid()::text, 'First16','', 'Last16','user16@example.com','555-0016','FEMALE',
   40.0,'USD',0,'pwd16','UTC','', '', NOW() - INTERVAL '16 days', NOW() + INTERVAL '14 days'),
  -- Row 17
  (gen_random_uuid()::text, 'First17','', 'Last17','user17@example.com','555-0017','MALE',
   42.5,'USD',1,'pwd17','UTC','', '', NOW() - INTERVAL '17 days', NOW() + INTERVAL '13 days'),
  -- Row 18
  (gen_random_uuid()::text, 'First18','', 'Last18','user18@example.com','555-0018','FEMALE',
   45.0,'USD',0,'pwd18','UTC','', '', NOW() - INTERVAL '18 days', NOW() + INTERVAL '12 days'),
  -- Row 19
  (gen_random_uuid()::text, 'First19','', 'Last19','user19@example.com','555-0019','MALE',
   47.5,'USD',1,'pwd19','UTC','', '', NOW() - INTERVAL '19 days', NOW() + INTERVAL '11 days'),
  -- Row 20
  (gen_random_uuid()::text, 'First20','', 'Last20','user20@example.com','555-0020','FEMALE',
   50.0,'USD',0,'pwd20','UTC','', '', NOW() - INTERVAL '20 days', NOW() + INTERVAL '10 days'),
  -- Row 21
  (gen_random_uuid()::text, 'First21','', 'Last21','user21@example.com','555-0021','MALE',
   52.5,'USD',1,'pwd21','UTC','', '', NOW() - INTERVAL '21 days', NOW() + INTERVAL '9 days'),
  -- Row 22
  (gen_random_uuid()::text, 'First22','', 'Last22','user22@example.com','555-0022','FEMALE',
   55.0,'USD',0,'pwd22','UTC','', '', NOW() - INTERVAL '22 days', NOW() + INTERVAL '8 days'),
  -- Row 23
  (gen_random_uuid()::text, 'First23','', 'Last23','user23@example.com','555-0023','MALE',
   57.5,'USD',1,'pwd23','UTC','', '', NOW() - INTERVAL '23 days', NOW() + INTERVAL '7 days'),
  -- Row 24
  (gen_random_uuid()::text, 'First24','', 'Last24','user24@example.com','555-0024','FEMALE',
   60.0,'USD',0,'pwd24','UTC','', '', NOW() - INTERVAL '24 days', NOW() + INTERVAL '6 days'),
  -- Row 25
  (gen_random_uuid()::text, 'First25','', 'Last25','user25@example.com','555-0025','MALE',
   62.5,'USD',1,'pwd25','UTC','', '', NOW() - INTERVAL '25 days', NOW() + INTERVAL '5 days'),
  -- Row 26
  (gen_random_uuid()::text, 'First26','', 'Last26','user26@example.com','555-0026','FEMALE',
   65.0,'USD',0,'pwd26','UTC','', '', NOW() - INTERVAL '26 days', NOW() + INTERVAL '4 days'),
  -- Row 27
  (gen_random_uuid()::text, 'First27','', 'Last27','user27@example.com','555-0027','MALE',
   67.5,'USD',1,'pwd27','UTC','', '', NOW() - INTERVAL '27 days', NOW() + INTERVAL '3 days'),
  -- Row 28
  (gen_random_uuid()::text, 'First28','', 'Last28','user28@example.com','555-0028','FEMALE',
   70.0,'USD',0,'pwd28','UTC','', '', NOW() - INTERVAL '28 days', NOW() + INTERVAL '2 days'),
  -- Row 29
  (gen_random_uuid()::text, 'First29','', 'Last29','user29@example.com','555-0029','MALE',
   72.5,'USD',1,'pwd29','UTC','', '', NOW() - INTERVAL '29 days', NOW() + INTERVAL '1 day'),
  -- Row 30
  (gen_random_uuid()::text, 'First30','', 'Last30','user30@example.com','555-0030','FEMALE',
   75.0,'USD',0,'pwd30','UTC','', '', NOW() - INTERVAL '30 days', NOW() + INTERVAL '0 days'),
  -- Row 31
  (gen_random_uuid()::text, 'First31','', 'Last31','user31@example.com','555-0031','MALE',
   77.5,'USD',1,'pwd31','UTC','', '', NOW() - INTERVAL '1 days',  NOW() + INTERVAL '29 days'),
  -- Row 32
  (gen_random_uuid()::text, 'First32','', 'Last32','user32@example.com','555-0032','FEMALE',
   80.0,'USD',0,'pwd32','UTC','', '', NOW() - INTERVAL '2 days',  NOW() + INTERVAL '28 days'),
  -- Row 33
  (gen_random_uuid()::text, 'First33','', 'Last33','user33@example.com','555-0033','MALE',
   82.5,'USD',1,'pwd33','UTC','', '', NOW() - INTERVAL '3 days',  NOW() + INTERVAL '27 days'),
  -- Row 34
  (gen_random_uuid()::text, 'First34','', 'Last34','user34@example.com','555-0034','FEMALE',
   85.0,'USD',0,'pwd34','UTC','', '', NOW() - INTERVAL '4 days',  NOW() + INTERVAL '26 days'),
  -- Row 35
  (gen_random_uuid()::text, 'First35','', 'Last35','user35@example.com','555-0035','MALE',
   87.5,'USD',1,'pwd35','UTC','', '', NOW() - INTERVAL '5 days',  NOW() + INTERVAL '25 days'),
  -- Row 36
  (gen_random_uuid()::text, 'First36','', 'Last36','user36@example.com','555-0036','FEMALE',
   90.0,'USD',0,'pwd36','UTC','', '', NOW() - INTERVAL '6 days',  NOW() + INTERVAL '24 days'),
  -- Row 37
  (gen_random_uuid()::text, 'First37','', 'Last37','user37@example.com','555-0037','MALE',
   92.5,'USD',1,'pwd37','UTC','', '', NOW() - INTERVAL '7 days',  NOW() + INTERVAL '23 days'),
  -- Row 38
  (gen_random_uuid()::text, 'First38','', 'Last38','user38@example.com','555-0038','FEMALE',
   95.0,'USD',0,'pwd38','UTC','', '', NOW() - INTERVAL '8 days',  NOW() + INTERVAL '22 days'),
  -- Row 39
  (gen_random_uuid()::text, 'First39','', 'Last39','user39@example.com','555-0039','MALE',
   97.5,'USD',1,'pwd39','UTC','', '', NOW() - INTERVAL '9 days',  NOW() + INTERVAL '21 days'),
  -- Row 40
  (gen_random_uuid()::text, 'First40','', 'Last40','user40@example.com','555-0040','FEMALE',
   100.0,'USD',0,'pwd40','UTC','', '', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days')
ON CONFLICT (uuid) DO NOTHING;


-- 9. Seed TEACHER (5 rows)
INSERT INTO teacher
  (uuid, status, first_name, middle_name, last_name, last_name_full_value,
   email, phone_personal, gender, profile_photo, goals,
   years_of_yoga_practise, years_of_yoga_teaching_experience,
   video_thumbnail, iana_timezone, slug)
VALUES
  (gen_random_uuid()::text,'APPROVED','TeacherA','','One','Teacher A One',
   'teacher1@example.com','555-1001','FEMALE','',
   'Mindfulness Basics', 3, 1,'','UTC','teacher-a-one'),
  (gen_random_uuid()::text,'APPROVED','TeacherB','','Two','Teacher B Two',
   'teacher2@example.com','555-1002','MALE','',
   'Vinyasa Flow', 5, 2,'','UTC','teacher-b-two'),
  (gen_random_uuid()::text,'UNDER_EVALUATION','TeacherC','','Three','Teacher C Three',
   'teacher3@example.com','555-1003','FEMALE','',
   'Hatha Yoga', 2, 1,'','UTC','teacher-c-three'),
  (gen_random_uuid()::text,'APPROVED','TeacherD','','Four','Teacher D Four',
   'teacher4@example.com','555-1004','MALE','',
   'Power Yoga', 4, 3,'','UTC','teacher-d-four'),
  (gen_random_uuid()::text,'INTERESTED_TO_JOIN','TeacherE','','Five','Teacher E Five',
   'teacher5@example.com','555-1005','FEMALE','',
   'Yin Yoga', 1, 0,'','UTC','teacher-e-five')
ON CONFLICT (uuid) DO NOTHING;


-- 10. Seed STUDENT_CONCIERGE (assign each of 40 students to one of 5 teachers)
INSERT INTO student_concierge (student_id, teacher_id)
VALUES
  (1,  1),  (2,  2),  (3,  3),  (4,  4),  (5,  5),
  (6,  1),  (7,  2),  (8,  3),  (9,  4),  (10, 5),
  (11, 1), (12,  2), (13,  3), (14,  4), (15,  5),
  (16, 1), (17,  2), (18,  3), (19,  4), (20,  5),
  (21, 1), (22,  2), (23,  3), (24,  4), (25,  5),
  (26, 1), (27,  2), (28,  3), (29,  4), (30,  5),
  (31, 1), (32,  2), (33,  3), (34,  4), (35,  5),
  (36, 1), (37,  2), (38,  3), (39,  4), (40,  5)
ON CONFLICT (student_id) DO NOTHING;


-- 11. Seed SESSION
-- For student_id = even numbers: insert one finished paid session
-- For student_id divisible by 5: also insert a future first‐trial session
INSERT INTO session
  (uuid, student_uuid, teacher_uuid, start_time, end_time, duration,
   status, is_trial, is_first_session, student_joined, teacher_joined,
   student_id, teacher_id, type)
VALUES
  -- Even IDs: one finished paid session (varied days ago)
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=2),
   (SELECT uuid FROM teacher WHERE id=(2 % 5) + 1),
   NOW() - INTERVAL '2 days',
   NOW() - INTERVAL '2 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 2, (2 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=4),
   (SELECT uuid FROM teacher WHERE id=(4 % 5) + 1),
   NOW() - INTERVAL '4 days',
   NOW() - INTERVAL '4 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 4, (4 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=6),
   (SELECT uuid FROM teacher WHERE id=(6 % 5) + 1),
   NOW() - INTERVAL '6 days',
   NOW() - INTERVAL '6 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 6, (6 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=8),
   (SELECT uuid FROM teacher WHERE id=(8 % 5) + 1),
   NOW() - INTERVAL '8 days',
   NOW() - INTERVAL '8 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 8, (8 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=10),
   (SELECT uuid FROM teacher WHERE id=(10 % 5) + 1),
   NOW() - INTERVAL '10 days',
   NOW() - INTERVAL '10 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 10, (10 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=12),
   (SELECT uuid FROM teacher WHERE id=(12 % 5) + 1),
   NOW() - INTERVAL '12 days',
   NOW() - INTERVAL '12 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 12, (12 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=14),
   (SELECT uuid FROM teacher WHERE id=(14 % 5) + 1),
   NOW() - INTERVAL '14 days',
   NOW() - INTERVAL '14 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 14, (14 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=16),
   (SELECT uuid FROM teacher WHERE id=(16 % 5) + 1),
   NOW() - INTERVAL '16 days',
   NOW() - INTERVAL '16 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 16, (16 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=18),
   (SELECT uuid FROM teacher WHERE id=(18 % 5) + 1),
   NOW() - INTERVAL '18 days',
   NOW() - INTERVAL '18 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 18, (18 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=20),
   (SELECT uuid FROM teacher WHERE id=(20 % 5) + 1),
   NOW() - INTERVAL '20 days',
   NOW() - INTERVAL '20 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 20, (20 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=22),
   (SELECT uuid FROM teacher WHERE id=(22 % 5) + 1),
   NOW() - INTERVAL '22 days',
   NOW() - INTERVAL '22 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 22, (22 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=24),
   (SELECT uuid FROM teacher WHERE id=(24 % 5) + 1),
   NOW() - INTERVAL '24 days',
   NOW() - INTERVAL '24 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 24, (24 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=26),
   (SELECT uuid FROM teacher WHERE id=(26 % 5) + 1),
   NOW() - INTERVAL '26 days',
   NOW() - INTERVAL '26 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 26, (26 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=28),
   (SELECT uuid FROM teacher WHERE id=(28 % 5) + 1),
   NOW() - INTERVAL '28 days',
   NOW() - INTERVAL '28 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 28, (28 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=30),
   (SELECT uuid FROM teacher WHERE id=(30 % 5) + 1),
   NOW() - INTERVAL '30 days',
   NOW() - INTERVAL '30 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 30, (30 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=32),
   (SELECT uuid FROM teacher WHERE id=(32 % 5) + 1),
   NOW() - INTERVAL '32 days',
   NOW() - INTERVAL '32 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 32, (32 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=34),
   (SELECT uuid FROM teacher WHERE id=(34 % 5) + 1),
   NOW() - INTERVAL '34 days',
   NOW() - INTERVAL '34 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 34, (34 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=36),
   (SELECT uuid FROM teacher WHERE id=(36 % 5) + 1),
   NOW() - INTERVAL '36 days',
   NOW() - INTERVAL '36 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 36, (36 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=38),
   (SELECT uuid FROM teacher WHERE id=(38 % 5) + 1),
   NOW() - INTERVAL '38 days',
   NOW() - INTERVAL '38 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 38, (38 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=40),
   (SELECT uuid FROM teacher WHERE id=(40 % 5) + 1),
   NOW() - INTERVAL '40 days',
   NOW() - INTERVAL '40 days' + INTERVAL '1 hour',
   60,'FINISHED',0,FALSE,1,1, 40, (40 % 5) + 1, 'YOGA'),
  -- IDs divisible by 5 get a future first trial session
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=5),
   (SELECT uuid FROM teacher WHERE id=(5 % 5) + 1),
   NOW() + INTERVAL '1 days',
   NOW() + INTERVAL '1 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 5, (5 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=10),
   (SELECT uuid FROM teacher WHERE id=(10 % 5) + 1),
   NOW() + INTERVAL '2 days',
   NOW() + INTERVAL '2 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 10, (10 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=15),
   (SELECT uuid FROM teacher WHERE id=(15 % 5) + 1),
   NOW() + INTERVAL '3 days',
   NOW() + INTERVAL '3 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 15, (15 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=20),
   (SELECT uuid FROM teacher WHERE id=(20 % 5) + 1),
   NOW() + INTERVAL '4 days',
   NOW() + INTERVAL '4 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 20, (20 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=25),
   (SELECT uuid FROM teacher WHERE id=(25 % 5) + 1),
   NOW() + INTERVAL '5 days',
   NOW() + INTERVAL '5 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 25, (25 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=30),
   (SELECT uuid FROM teacher WHERE id=(30 % 5) + 1),
   NOW() + INTERVAL '6 days',
   NOW() + INTERVAL '6 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 30, (30 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=35),
   (SELECT uuid FROM teacher WHERE id=(35 % 5) + 1),
   NOW() + INTERVAL '7 days',
   NOW() + INTERVAL '7 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 35, (35 % 5) + 1, 'YOGA'),
  (gen_random_uuid()::text,
   (SELECT uuid FROM student WHERE id=40),
   (SELECT uuid FROM teacher WHERE id=(40 % 5) + 1),
   NOW() + INTERVAL '8 days',
   NOW() + INTERVAL '8 days' + INTERVAL '1 hour',
   60,'SCHEDULED',1, TRUE,0,0, 40, (40 % 5) + 1, 'YOGA')
ON CONFLICT (uuid) DO NOTHING;


-- 12. Seed TRANSACTION (20 rows for even‐numbered students)
INSERT INTO transaction
  (student_uuid, package_id, currency, type, recurring, order_id,
   next_billing_date, subscription_status, purchase_date, user_agent,
   student_id)
VALUES
  -- IDs 2,4,...,40 each get one NEW transaction
  ((SELECT uuid FROM student WHERE id=2),   1002, 'USD', 'NEW',      1, 'ORD2002', NOW() + INTERVAL '30 days', 'ACTIVE', NOW() - INTERVAL '2 days',  'Mozilla/5.0',  2),
  ((SELECT uuid FROM student WHERE id=4),   1004, 'USD', 'NEW',      1, 'ORD2004', NOW() + INTERVAL '28 days', 'ACTIVE', NOW() - INTERVAL '4 days',  'Mozilla/5.0',  4),
  ((SELECT uuid FROM student WHERE id=6),   1006, 'USD', 'NEW',      1, 'ORD2006', NOW() + INTERVAL '26 days', 'ACTIVE', NOW() - INTERVAL '6 days',  'Mozilla/5.0',  6),
  ((SELECT uuid FROM student WHERE id=8),   1008, 'USD', 'NEW',      1, 'ORD2008', NOW() + INTERVAL '24 days', 'ACTIVE', NOW() - INTERVAL '8 days',  'Mozilla/5.0',  8),
  ((SELECT uuid FROM student WHERE id=10), 1010, 'USD', 'NEW',     1, 'ORD2010', NOW() + INTERVAL '22 days', 'ACTIVE', NOW() - INTERVAL '10 days', 'Mozilla/5.0', 10),
  ((SELECT uuid FROM student WHERE id=12), 1012, 'USD', 'NEW',     1, 'ORD2012', NOW() + INTERVAL '20 days', 'ACTIVE', NOW() - INTERVAL '12 days', 'Mozilla/5.0', 12),
  ((SELECT uuid FROM student WHERE id=14), 1014, 'USD', 'NEW',     1, 'ORD2014', NOW() + INTERVAL '18 days', 'ACTIVE', NOW() - INTERVAL '14 days', 'Mozilla/5.0', 14),
  ((SELECT uuid FROM student WHERE id=16), 1016, 'USD', 'NEW',     1, 'ORD2016', NOW() + INTERVAL '16 days', 'ACTIVE', NOW() - INTERVAL '16 days', 'Mozilla/5.0', 16),
  ((SELECT uuid FROM student WHERE id=18), 1018, 'USD', 'NEW',     1, 'ORD2018', NOW() + INTERVAL '14 days', 'ACTIVE', NOW() - INTERVAL '18 days', 'Mozilla/5.0', 18),
  ((SELECT uuid FROM student WHERE id=20), 1020, 'USD', 'NEW',     1, 'ORD2020', NOW() + INTERVAL '12 days', 'ACTIVE', NOW() - INTERVAL '20 days', 'Mozilla/5.0', 20),
  ((SELECT uuid FROM student WHERE id=22), 1022, 'USD', 'NEW',     1, 'ORD2022', NOW() + INTERVAL '10 days', 'ACTIVE', NOW() - INTERVAL '22 days', 'Mozilla/5.0', 22),
  ((SELECT uuid FROM student WHERE id=24), 1024, 'USD', 'NEW',     1, 'ORD2024', NOW() + INTERVAL '8 days',  'ACTIVE', NOW() - INTERVAL '24 days', 'Mozilla/5.0', 24),
  ((SELECT uuid FROM student WHERE id=26), 1026, 'USD', 'NEW',     1, 'ORD2026', NOW() + INTERVAL '6 days',  'ACTIVE', NOW() - INTERVAL '26 days', 'Mozilla/5.0', 26),
  ((SELECT uuid FROM student WHERE id=28), 1028, 'USD', 'NEW',     1, 'ORD2028', NOW() + INTERVAL '4 days',  'ACTIVE', NOW() - INTERVAL '28 days', 'Mozilla/5.0', 28),
  ((SELECT uuid FROM student WHERE id=30), 1030, 'USD', 'NEW',     1, 'ORD2030', NOW() + INTERVAL '2 days',  'ACTIVE', NOW() - INTERVAL '30 days', 'Mozilla/5.0', 30),
  ((SELECT uuid FROM student WHERE id=32), 1032, 'USD', 'NEW',     1, 'ORD2032', NOW() + INTERVAL '1 day',   'ACTIVE', NOW() - INTERVAL '32 days', 'Mozilla/5.0', 32),
  ((SELECT uuid FROM student WHERE id=34), 1034, 'USD', 'NEW',     1, 'ORD2034', NOW() - INTERVAL '1 day',   'PAUSED', NOW() - INTERVAL '34 days', 'Mozilla/5.0', 34),
  ((SELECT uuid FROM student WHERE id=36), 1036, 'USD', 'NEW',     1, 'ORD2036', NOW() - INTERVAL '3 days',  'PAUSED', NOW() - INTERVAL '36 days', 'Mozilla/5.0', 36),
  ((SELECT uuid FROM student WHERE id=38), 1038, 'USD', 'NEW',     1, 'ORD2038', NOW() - INTERVAL '5 days',  'CANCELLED', NOW() - INTERVAL '38 days', 'Mozilla/5.0', 38),
  ((SELECT uuid FROM student WHERE id=40), 1040, 'USD', 'NEW',     1, 'ORD2040', NOW() - INTERVAL '7 days',  'CANCELLED', NOW() - INTERVAL '40 days', 'Mozilla/5.0', 40)
ON CONFLICT (order_id) DO NOTHING;


-- 13. Seed MEMBERSHIP (20 rows for even‐numbered students)
INSERT INTO membership (student_id, start_date, end_date, is_active, next_renewal_date)
VALUES
  (2, NOW() - INTERVAL '2 days',  NOW() + INTERVAL '28 days', TRUE,  NOW() + INTERVAL '28 days'),
  (4, NOW() - INTERVAL '4 days',  NOW() + INTERVAL '26 days', TRUE,  NOW() + INTERVAL '26 days'),
  (6, NOW() - INTERVAL '6 days',  NOW() + INTERVAL '24 days', TRUE,  NOW() + INTERVAL '24 days'),
  (8, NOW() - INTERVAL '8 days',  NOW() + INTERVAL '22 days', TRUE,  NOW() + INTERVAL '22 days'),
  (10,NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days', TRUE,  NOW() + INTERVAL '20 days'),
  (12,NOW() - INTERVAL '12 days', NOW() + INTERVAL '18 days', TRUE,  NOW() + INTERVAL '18 days'),
  (14,NOW() - INTERVAL '14 days', NOW() + INTERVAL '16 days', TRUE,  NOW() + INTERVAL '16 days'),
  (16,NOW() - INTERVAL '16 days', NOW() + INTERVAL '14 days', TRUE,  NOW() + INTERVAL '14 days'),
  (18,NOW() - INTERVAL '18 days', NOW() + INTERVAL '12 days', TRUE,  NOW() + INTERVAL '12 days'),
  (20,NOW() - INTERVAL '20 days', NOW() + INTERVAL '10 days', TRUE,  NOW() + INTERVAL '10 days'),
  (22,NOW() - INTERVAL '22 days', NOW() + INTERVAL '8 days',  TRUE,  NOW() + INTERVAL '8 days'),
  (24,NOW() - INTERVAL '24 days', NOW() + INTERVAL '6 days',  TRUE,  NOW() + INTERVAL '6 days'),
  (26,NOW() - INTERVAL '26 days', NOW() + INTERVAL '4 days',  TRUE,  NOW() + INTERVAL '4 days'),
  (28,NOW() - INTERVAL '28 days', NOW() + INTERVAL '2 days',  TRUE,  NOW() + INTERVAL '2 days'),
  (30,NOW() - INTERVAL '30 days', NOW() + INTERVAL '0 days',  TRUE,  NOW() + INTERVAL '0 days'),
  (32,NOW() - INTERVAL '32 days', NOW() - INTERVAL '2 days',  FALSE, NULL),
  (34,NOW() - INTERVAL '34 days', NOW() - INTERVAL '4 days',  FALSE, NULL),
  (36,NOW() - INTERVAL '36 days', NOW() - INTERVAL '6 days',  FALSE, NULL),
  (38,NOW() - INTERVAL '38 days', NOW() - INTERVAL '8 days',  FALSE, NULL),
  (40,NOW() - INTERVAL '40 days', NOW() - INTERVAL '10 days', FALSE, NULL)
ON CONFLICT (student_id) DO NOTHING;
