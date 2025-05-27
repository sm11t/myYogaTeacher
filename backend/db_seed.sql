-- create tables
CREATE TABLE IF NOT EXISTS app_user (
  id SERIAL PRIMARY KEY,
  uuid UUID DEFAULT gen_random_uuid(),
  name VARCHAR(50),
  email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS report (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES app_user(id),
  title VARCHAR(100),
  created_at TIMESTAMP DEFAULT now()
);

-- insert dummy rows
INSERT INTO app_user (name, email) VALUES
  ('Alice Lee',  'alice@example.com'),
  ('Bob Patel',  'bob.patel@example.com'),
  ('Carol Wong', 'carol@foo.com');

INSERT INTO report (user_id, title) VALUES
  (1, 'Weekly Summary'),
  (2, 'Monthly Metrics'),
  (3, 'Onboarding Report');
