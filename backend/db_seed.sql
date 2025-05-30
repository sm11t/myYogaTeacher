-- backend/db_seed.sql

-- 0. Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Cleanup old tables (drop in child‐first order)
DROP TABLE IF EXISTS student_concierge CASCADE;
DROP TABLE IF EXISTS session           CASCADE;
DROP TABLE IF EXISTS transaction       CASCADE;
DROP TABLE IF EXISTS teacher           CASCADE;
DROP TABLE IF EXISTS student           CASCADE;

-- 2. STUDENT
CREATE TABLE student (
  id                          SERIAL      PRIMARY KEY,
  uuid                        VARCHAR(100) NOT NULL UNIQUE,
  created_date                TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_date               TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  first_name                  VARCHAR(100) DEFAULT '',
  middle_name                 VARCHAR(100) DEFAULT '',
  last_name                   VARCHAR(100) DEFAULT '',
  email                       VARCHAR(255),
  phone_personal              VARCHAR(45)  DEFAULT '',
  gender                      VARCHAR(50),
  credits                     FLOAT       DEFAULT 0,
  credits_currency            VARCHAR(45) DEFAULT 'USD',
  is_credits_currency_fixed   SMALLINT    NOT NULL DEFAULT 0,
  password                    VARCHAR(100),
  iana_timezone               VARCHAR(255) DEFAULT '',
  funnel_url                  VARCHAR(1000) DEFAULT '',
  funnel_type                 VARCHAR(255) NOT NULL DEFAULT '',
  trial_start_date            TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  trial_end_date              TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. TEACHER
CREATE TABLE teacher (
  id                              SERIAL      PRIMARY KEY,
  uuid                            VARCHAR(100) NOT NULL UNIQUE,
  status                          VARCHAR(50)  NOT NULL DEFAULT 'INTERESTED_TO_JOIN',
  created_date                    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  modified_date                   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  first_name                      VARCHAR(45)  DEFAULT '',
  middle_name                     VARCHAR(45)  DEFAULT '',
  last_name                       VARCHAR(45)  DEFAULT '',
  last_name_full_value            VARCHAR(45)  DEFAULT '',
  email                           VARCHAR(255),
  phone_personal                  VARCHAR(45),
  gender                          VARCHAR(6),
  profile_photo                   VARCHAR(500) NOT NULL DEFAULT '',
  goals                           TEXT,
  years_of_yoga_practise          INT          DEFAULT 0,
  years_of_yoga_teaching_experience INT        DEFAULT 0,
  video_thumbnail                 VARCHAR(255) DEFAULT '',
  iana_timezone                   VARCHAR(255) DEFAULT '',
  slug                            VARCHAR(100) NOT NULL DEFAULT ''
);

-- 4. STUDENT_CONCIERGE
CREATE TABLE student_concierge (
  id            SERIAL      PRIMARY KEY,
  student_id    INT         NOT NULL REFERENCES student(id),
  teacher_id    INT         NOT NULL REFERENCES teacher(id),
  created_date  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified_date TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. SESSION
CREATE TABLE session (
  id             SERIAL      PRIMARY KEY,
  uuid           VARCHAR(100) NOT NULL UNIQUE,
  student_uuid   VARCHAR(100) NOT NULL REFERENCES student(uuid),
  teacher_uuid   VARCHAR(100) NOT NULL REFERENCES teacher(uuid),
  start_time     TIMESTAMP,
  end_time       TIMESTAMP,
  duration       INT          DEFAULT 60,
  status         VARCHAR(32),
  is_trial       INT          DEFAULT 0,
  student_joined INT          DEFAULT 0,
  teacher_joined INT          DEFAULT 0,
  created_date   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  modified_date  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  student_id     INT          NOT NULL REFERENCES student(id),
  teacher_id     INT          NOT NULL REFERENCES teacher(id),
  type           VARCHAR(16)
);

-- 6. TRANSACTION
CREATE TABLE transaction (
  id                  SERIAL      PRIMARY KEY,
  student_uuid        VARCHAR(100)    REFERENCES student(uuid),
  package_id          INT,
  currency            VARCHAR(3),
  type                VARCHAR(20) NOT NULL DEFAULT 'PAY_PER_USE',
  recurring           INT         DEFAULT 0,
  order_id            VARCHAR(45) DEFAULT '',
  next_billing_date   TIMESTAMP,
  subscription_status VARCHAR(16),
  purchase_date       TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
  user_agent          VARCHAR(1000) DEFAULT '',
  created_date        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
  modified_date       TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
  student_id          INT         REFERENCES student(id)
);

-- 7. Seed STUDENT
INSERT INTO student (uuid, first_name, middle_name, last_name, email, phone_personal, gender, credits, credits_currency, is_credits_currency_fixed, password, iana_timezone, funnel_url, funnel_type, trial_start_date, trial_end_date)
VALUES
  (gen_random_uuid()::text, 'Alice', '', 'Lee', 'alice.lee@example.com', '555-0101', 'FEMALE', 10, 'USD', 1, 'passwd123', 'America/New_York', 'https://funnel.example.com', 'signup', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
  (gen_random_uuid()::text, 'Bob', 'J.', 'Patel', 'bob.patel@example.com', '555-0202', 'MALE', 5, 'EUR', 0, 'secret', 'Europe/London', 'https://funnel.example.com', 'trial', NOW() - INTERVAL '30 days', NOW() - INTERVAL '1 day'),
  (gen_random_uuid()::text, 'Carol', '', 'Wong', 'carol.wong@example.com', '555-0303', 'FEMALE', 20, 'INR', 1, 'pwd', 'Asia/Kolkata', 'https://funnel.example.com', 'promo', NOW() - INTERVAL '5 days', NOW() + INTERVAL '25 days');

-- 8. Seed TEACHER
INSERT INTO teacher (uuid, status, first_name, middle_name, last_name, last_name_full_value, email, phone_personal, gender, profile_photo, goals, years_of_yoga_practise, years_of_yoga_teaching_experience, video_thumbnail, iana_timezone, slug)
VALUES
  (gen_random_uuid()::text, 'APPROVED', 'Drake', '', 'Ramirez', 'Drake Ramirez', 'drake.r@example.com', '555-1001', 'MALE', '', 'Mindfulness', 3, 1, '', 'America/Los_Angeles', 'drake-ramirez'),
  (gen_random_uuid()::text, 'UNDER_EVALUATION', 'Eva', '', 'Chen', 'Eva Chen', 'eva.chen@example.com', '555-1002', 'FEMALE', '', 'Vinyasa', 5, 2, '', 'Asia/Hong_Kong', 'eva-chen'),
  (gen_random_uuid()::text, 'INTERESTED_TO_JOIN', 'Frank', '', 'Nguyen', 'Frank Nguyen', 'frank.n@example.com', '555-1003', 'MALE', '', 'Hatha', 2, 0, '', 'Europe/Berlin', 'frank-nguyen');

-- 9. Seed STUDENT_CONCIERGE
INSERT INTO student_concierge (student_id, teacher_id)
VALUES
  (1, 1),
  (2, 2),
  (3, 3);

-- 10. Seed SESSION
INSERT INTO session (uuid, student_uuid, teacher_uuid, start_time, end_time, duration, status, is_trial, student_joined, teacher_joined, student_id, teacher_id, type)
VALUES
  (gen_random_uuid()::text, (SELECT uuid FROM student WHERE id=1), (SELECT uuid FROM teacher WHERE id=1), NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '1 hour', 60, 'FINISHED', 0, 1, 1, 1, 1, 'YOGA'),
  (gen_random_uuid()::text, (SELECT uuid FROM student WHERE id=2), (SELECT uuid FROM teacher WHERE id=2), NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day' + INTERVAL '1 hour', 60, 'SCHEDULED', 1, 0, 0, 2, 2, 'GROUP_SESSION'),
  (gen_random_uuid()::text, (SELECT uuid FROM student WHERE id=3), (SELECT uuid FROM teacher WHERE id=3), NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '30 minutes', 30, 'CANCELLED', 0, 0, 0, 3, 3, 'YOGA');

-- 11. Seed TRANSACTION
INSERT INTO transaction (student_uuid, package_id, currency, type, recurring, order_id, next_billing_date, subscription_status, purchase_date, user_agent, student_id)
VALUES
  ((SELECT uuid FROM student WHERE id=1), 101, 'USD', 'PAY_PER_USE', 0, 'ORD1001', NULL, 'ACTIVE', NOW() - INTERVAL '3 days', 'Mozilla/5.0', 1),
  ((SELECT uuid FROM student WHERE id=2), 102, 'EUR', 'REFUND', 0, 'ORD1002', NULL, 'CANCELLED', NOW() - INTERVAL '10 days', 'Mozilla/5.0', 2),
  ((SELECT uuid FROM student WHERE id=3), 103, 'INR', 'NEW', 1, 'ORD1003', NOW() + INTERVAL '27 days', 'PAUSED', NOW() - INTERVAL '1 day', 'Mozilla/5.0', 3);
