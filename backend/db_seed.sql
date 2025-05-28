-- db_seed.sql

-- 1. STUDENT
CREATE TABLE IF NOT EXISTS student (
  id             SERIAL    PRIMARY KEY,
  uuid           UUID      DEFAULT gen_random_uuid() UNIQUE,
  first_name     VARCHAR(50),
  last_name      VARCHAR(50),
  email          VARCHAR(100),
  phone_personal VARCHAR(20),
  credits        INT       DEFAULT 0
);

-- 2. TEACHER
CREATE TABLE IF NOT EXISTS teacher (
  id         SERIAL    PRIMARY KEY,
  uuid       UUID      DEFAULT gen_random_uuid() UNIQUE,
  status     VARCHAR(20),
  first_name VARCHAR(50),
  last_name  VARCHAR(50),
  slug       VARCHAR(100)
);

-- 3. STUDENT_CONCIERGE (join table)
CREATE TABLE IF NOT EXISTS student_concierge (
  student_id INT REFERENCES student(id),
  teacher_id INT REFERENCES teacher(id),
  PRIMARY KEY (student_id, teacher_id)
);

-- 4. SESSION
CREATE TABLE IF NOT EXISTS session (
  id            SERIAL    PRIMARY KEY,
  student_uuid  UUID      REFERENCES student(uuid),
  teacher_uuid  UUID      REFERENCES teacher(uuid),
  status        VARCHAR(20),
  start_time    TIMESTAMP,
  end_time      TIMESTAMP
);

-- 5. TRANSACTION
CREATE TABLE IF NOT EXISTS transaction (
  id            SERIAL    PRIMARY KEY,
  student_uuid  UUID      REFERENCES student(uuid),
  package_id    INT,
  currency      VARCHAR(10),
  type          VARCHAR(20),
  purchase_date TIMESTAMP DEFAULT now()
);

-- Seed STUDENT
INSERT INTO student (first_name, last_name, email, phone_personal, credits) VALUES
  ('Alice',   'Lee',    'alice.lee@example.com',   '555-0101', 10),
  ('Bob',     'Patel',  'bob.patel@example.com',   '555-0202', 20),
  ('Carol',   'Wong',   'carol.wong@example.com',  '555-0303', 15);

-- Seed TEACHER
INSERT INTO teacher (status, first_name, last_name, slug) VALUES
  ('active', 'Drake',   'Ramirez',  'drake-ramirez'),
  ('active', 'Eva',     'Chen',     'eva-chen'),
  ('inactive','Frank',  'Nguyen',   'frank-nguyen');

-- Seed STUDENT_CONCIERGE
INSERT INTO student_concierge (student_id, teacher_id) VALUES
  (1, 1),
  (2, 2),
  (3, 1);

-- Seed SESSION
INSERT INTO session (student_uuid, teacher_uuid, status, start_time, end_time) VALUES
  ((SELECT uuid FROM student WHERE id=1), (SELECT uuid FROM teacher WHERE id=1), 'completed', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '1 hour'),
  ((SELECT uuid FROM student WHERE id=2), (SELECT uuid FROM teacher WHERE id=2), 'booked',    NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day' + INTERVAL '1 hour'),
  ((SELECT uuid FROM student WHERE id=3), (SELECT uuid FROM teacher WHERE id=1), 'cancelled',NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '30 minutes');

-- Seed TRANSACTION
INSERT INTO transaction (student_uuid, package_id, currency, type) VALUES
  ((SELECT uuid FROM student WHERE id=1), 101, 'USD', 'purchase'),
  ((SELECT uuid FROM student WHERE id=2), 102, 'USD', 'refund'),
  ((SELECT uuid FROM student WHERE id=3), 101, 'EUR', 'purchase');
