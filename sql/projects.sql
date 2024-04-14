CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    task_id INT,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO projects (task_id, start_date, end_date) VALUES (1, '2024-10-01', '2024-10-02');
INSERT INTO projects (task_id, start_date, end_date) VALUES (2, '2024-10-02', '2024-10-03');
INSERT INTO projects (task_id, start_date, end_date) VALUES (3, '2024-10-03', '2024-10-04');
INSERT INTO projects (task_id, start_date, end_date) VALUES (4, '2024-10-10', '2024-10-11');
INSERT INTO projects (task_id, start_date, end_date) VALUES (5, '2024-10-20', '2024-10-21');
INSERT INTO projects (task_id, start_date, end_date) VALUES (6, '2024-10-21', '2024-10-22');