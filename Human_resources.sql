-- Create 'departments' table
CREATE TABLE departments (
    id INT PRIMARY KEY IDENTITY (1,1),
    name VARCHAR(50),
    manager_id INT
);

-- Create 'employees' table
CREATE TABLE employees (
    id INT PRIMARY KEY IDENTITY (1,1),
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

-- Create 'projects' table
CREATE TABLE projects (
    id INT PRIMARY KEY IDENTITY (1,1),
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

-- Insert data into 'departments'
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
       
       UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
WHERE name = 'Sales';

-- SQL Challenge Questions

--1. Find the longest ongoing project for each department.
SELECT
MAX(DATE_PART(
    'day',p.end_date::timestamp - p.start_date::timestamp)) AS max_duration_days,
d.name
FROM projects p 
JOIN departments d 
ON p.department_id =d.id
GROUP BY d.name;

--2. Find all employees who are not managers.
SELECT name, job_title
FROM employees
WHERE job_title NOT IN (
						SELECT job_title FROM employees
						WHERE job_title LIKE '%_Managers');
  
--3. Find all employees who have been hired after the start of a project in their department.
SELECT e.name
FROM employees e
JOIN projects p
ON e.department_id = p.department_id
WHERE hire_date > p.start_date;

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).
SELECT e.name,
	d.name,
    e.hire_date,
    RANK()
    OVER(PARTITION BY d.name
        	ORDER BY e.hire_date ASC)
FROM employees e
JOIN departments d
ON e.department_id = d.id;

--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
SELECT e.name,
		d.name,
        e.hire_date,
LEAD(e.hire_date) OVER(PARTITION BY d.name
					ORDER BY e.hire_date) AS next_hire,
LEAD(e.hire_date) OVER(PARTITION BY d.name
					ORDER BY e.hire_date)-e.hire_date AS duration_days
FROM employees e
JOIN departments d
ON e.department_id = d.id
ORDER BY d.name, e.hire_date;