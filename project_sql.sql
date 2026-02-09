-- create database project1;

use project1;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from payroll;

-- How many unique employees are currently in the system?

SELECT COUNT(DISTINCT emp_ID) AS total_employees
FROM employee;

-- Which departments have the highest number of employees?
SELECT jd.name AS department_name,
       AVG(sb.amount) AS avg_salary
FROM jobdepartment jd
JOIN salarybonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.name;

-- What is the average salary per department?
SELECT jd.name AS department_name,
       AVG(sb.amount) AS avg_salary
FROM employee e
JOIN salarybonus sb ON e.Job_ID = sb.Job_ID
JOIN jobdepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.name;


-- Who are the top 5 highest-paid employees?
SELECT e.firstname, e.lastname, sb.amount
FROM employee e
JOIN salarybonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(sb.amount) AS total_salary_expenditure
FROM salarybonus sb;


-- How many different job roles exist in each department?
SELECT name AS department_name,
       COUNT(DISTINCT jobdept) AS job_roles
FROM jobdepartment
GROUP BY name;

-- What is the average salary range per department?
SELECT jd.name AS department_name,
       AVG(sb.amount) AS avg_salary
FROM jobdepartment jd
JOIN salarybonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.name;

-- Which job roles offer the highest salary?
SELECT jd.jobdept AS job_role,
       sb.amount
FROM jobdepartment jd
JOIN salarybonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC;

-- Which departments have the highest total salary allocation?
SELECT jd.name AS department_name,
       SUM(sb.amount) AS total_salary
FROM jobdepartment jd
JOIN salarybonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.name
ORDER BY total_salary DESC;

-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS employees_with_qualification
FROM qualification;

-- Which positions require the most qualifications?
SELECT Position,
       COUNT(*) AS qualification_count
FROM qualification
GROUP BY Position
ORDER BY qualification_count DESC;

-- Which employees have the highest number of qualifications?
SELECT e.firstname, e.lastname,
       COUNT(q.QualID) AS total_qualifications
FROM employee e
JOIN qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_qualifications DESC;

-- Which year had the most employees taking leaves?
SELECT YEAR(date) AS leave_year,
       COUNT(DISTINCT emp_ID) AS employee_count
FROM leaves
GROUP BY leave_year
ORDER BY employee_count DESC;

-- Average number of leave days taken per department

SELECT jd.name AS department_name,
       AVG(lc.leave_count) AS avg_leave_days
FROM (
    SELECT emp_ID, COUNT(*) AS leave_count
    FROM leaves
    GROUP BY emp_ID
) lc
JOIN employee e ON lc.emp_ID = e.emp_ID
JOIN jobdepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.name;

-- Which employees have taken the most leaves?
SELECT e.firstname, e.lastname,
       COUNT(l.leave_ID) AS total_leaves
FROM employee e
JOIN leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID
ORDER BY total_leaves DESC;

-- Total number of leave days taken company-wide
SELECT COUNT(*) AS total_leave_days
FROM leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.emp_ID,
       COUNT(l.leave_ID) AS total_leaves,
       AVG(p.total_amount) AS avg_payroll_amount
FROM employee e
LEFT JOIN leaves l ON e.emp_ID = l.emp_ID
JOIN payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID;

-- What is the total monthly payroll processed?
SELECT MONTH(date) AS payroll_month,
       YEAR(date) AS payroll_year,
       SUM(total_amount) AS total_payroll
FROM payroll
GROUP BY payroll_year, payroll_month;

-- What is the average bonus given per department?
SELECT jd.name AS department_name,
       AVG(sb.bonus) AS avg_bonus
FROM salarybonus sb
JOIN jobdepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.name;

-- Which department receives the highest total bonuses?
SELECT jd.name AS department_name,
       SUM(sb.bonus) AS total_bonus
FROM salarybonus sb
JOIN jobdepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.name
ORDER BY total_bonus DESC;

-- Average value of total_amount after considering leave deductions
SELECT AVG(total_amount) AS avg_final_salary
FROM payroll;
