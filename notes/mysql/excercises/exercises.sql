-- ============================================================
-- SQL 练习题集 (MySQL 版)
-- ============================================================
-- 使用方法：
--   1. 创建数据库并执行本脚本
--      mysql -u root -p
--      CREATE DATABASE sqlstudy;
--      USE sqlstudy;
--      source /path/to/exercises.sql;
--
--   2. 或者一行搞定：
--      mysql -u root -p sqlstudy < exercises.sql
--      （需提前 CREATE DATABASE sqlstudy）
-- ============================================================

CREATE DATABASE IF NOT EXISTS sqlstudy DEFAULT CHARACTER SET utf8mb4;
USE sqlstudy;

-- ============================================================
-- 第一部分：建表与测试数据
-- ============================================================

DROP TABLE IF EXISTS employee_projects;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- 部门表
CREATE TABLE departments (
    dept_id   INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL
);

-- 员工表
CREATE TABLE employees (
    emp_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_name   VARCHAR(50) NOT NULL,
    dept_id    INT,
    salary     DECIMAL(10, 2),
    hire_date  DATE,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

-- 项目表
CREATE TABLE projects (
    project_id   INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    budget       DECIMAL(10, 2),
    start_date   DATE
);

-- 员工-项目关联表（多对多）
CREATE TABLE employee_projects (
    emp_id     INT,
    project_id INT,
    role       VARCHAR(50),
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- ============================================================
-- 插入测试数据
-- ============================================================

INSERT INTO departments (dept_id, dept_name) VALUES (1, '技术部');
INSERT INTO departments (dept_id, dept_name) VALUES (2, '市场部');
INSERT INTO departments (dept_id, dept_name) VALUES (3, '财务部');
INSERT INTO departments (dept_id, dept_name) VALUES (4, '人事部');

INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (1,  '张三',   1, 25000, '2020-03-15', NULL);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (2,  '李四',   1, 18000, '2021-06-01', 1);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (3,  '王五',   1, 15000, '2022-01-10', 1);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (4,  '赵六',   2, 20000, '2019-11-20', NULL);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (5,  '孙七',   2, 12000, '2023-02-28', 4);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (6,  '周八',   3, 22000, '2018-07-05', NULL);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (7,  '吴九',   3, 14000, '2022-09-15', 6);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (8,  '郑十',   1, 16000, '2021-03-20', 1);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (9,  '钱一一', 4, 19000, '2020-08-10', NULL);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (10, '刘二',   2, 11000, '2023-07-01', 4);

INSERT INTO projects (project_id, project_name, budget, start_date) VALUES (1, '电商平台重构', 500000, '2024-01-01');
INSERT INTO projects (project_id, project_name, budget, start_date) VALUES (2, '数据分析平台', 300000, '2024-03-15');
INSERT INTO projects (project_id, project_name, budget, start_date) VALUES (3, '市场调研报告',  80000, '2024-02-01');
INSERT INTO projects (project_id, project_name, budget, start_date) VALUES (4, '年度审计',      60000, '2024-04-01');
INSERT INTO projects (project_id, project_name, budget, start_date) VALUES (5, '招聘系统',     120000, '2024-05-01');

INSERT INTO employee_projects VALUES (1,  1, '架构师');
INSERT INTO employee_projects VALUES (2,  1, '开发');
INSERT INTO employee_projects VALUES (3,  1, '开发');
INSERT INTO employee_projects VALUES (8,  1, '测试');
INSERT INTO employee_projects VALUES (1,  2, '架构师');
INSERT INTO employee_projects VALUES (3,  2, '开发');
INSERT INTO employee_projects VALUES (4,  3, '负责人');
INSERT INTO employee_projects VALUES (5,  3, '分析师');
INSERT INTO employee_projects VALUES (6,  4, '负责人');
INSERT INTO employee_projects VALUES (7,  4, '审计员');
INSERT INTO employee_projects VALUES (9,  5, '负责人');
INSERT INTO employee_projects VALUES (2,  5, '开发');

-- ============================================================
-- 第二部分：练习题（题目）
-- ============================================================

-- ────────── Level 1: 基础查询 ──────────

-- 第 1 题：查询所有员工的姓名和工资

-- 第 2 题：查询工资大于 15000 的员工姓名、部门和工资

-- 第 3 题：查询每个部门的员工人数

-- 第 4 题：查询工资最高的前 3 名员工

-- 第 5 题：查询姓名中包含"七"字的员工

-- ────────── Level 2: 聚合与分组 ──────────

-- 第 6 题：查询每个部门的平均工资，按平均工资降序排列

-- 第 7 题：查询员工人数大于 2 的部门名称和人数

-- 第 8 题：查询 2022 年之后入职的员工总数

-- 第 9 题：查询每个部门的工资总和，只显示总和超过 30000 的部门

-- 第 10 题：查询各部门最高工资和最低工资的差值

-- ────────── Level 3: 多表连接 ──────────

-- 第 11 题：查询每个员工参与的项目名称（含未参与项目的员工）

-- 第 12 题：查询参与了"电商平台重构"项目的所有员工姓名和角色

-- 第 13 题：查询预算超过 100000 的项目中，每位员工的姓名、项目名和角色

-- 第 14 题：查询每位经理（有下级员工的人）及其直接下属的姓名

-- 第 15 题：查询没有参与任何项目的员工

-- ────────── Level 4: 子查询 ──────────

-- 第 16 题：查询工资高于公司平均工资的员工

-- 第 17 题：查询工资高于其所在部门平均工资的员工

-- 第 18 题：查询参与了项目最多的员工姓名和参与项目数

-- 第 19 题：查询每个部门中工资最高的员工信息

-- 第 20 题：查询预算高于所有项目平均预算的项目，列出项目名和超出金额

-- ────────── Level 5: 进阶（窗口函数 / CTE / CASE） ──────────

-- 第 21 题：用窗口函数给员工按工资排名（全公司排名）

-- 第 22 题：用窗口函数在每个部门内按工资排名

-- 第 23 题：用 CTE (WITH 子句) 查询平均工资最高的部门

-- 第 24 题：用 CASE 语句将员工按工资分为三档：高薪(>=20000)、中薪(15000-19999)、低薪(<15000)

-- 第 25 题：用窗口函数计算每位员工与其部门平均工资的差值

-- ────────── Level 6: 数据修改 ──────────

-- 第 26 题：给技术部所有员工涨薪 10%

-- 第 27 题：删除没有参与任何项目的员工（请先用 SELECT 确认，再 DELETE）

-- 第 28 题：插入一个新部门"法务部"，并插入该部门一名新员工

-- ────────── Level 7: 综合挑战 ──────────

-- 第 29 题：查询每个项目中工资最高的员工姓名、项目名、工资

-- 第 30 题：生成一份报表，列出：部门名、部门人数、部门平均工资、部门总工资、
--          部门最高薪、部门最低薪，按部门总工资降序排列

-- ============================================================
-- 第三部分：参考答案（做完再看！）
-- ============================================================

-- 第 1 题
-- SELECT emp_name, salary FROM employees;

-- 第 2 题
-- SELECT e.emp_name, d.dept_name, e.salary
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id
-- WHERE e.salary > 15000;

-- 第 3 题
-- SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
-- FROM departments d
-- LEFT JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_name;

-- 第 4 题
-- SELECT emp_name, salary FROM employees
-- ORDER BY salary DESC LIMIT 3;

-- 第 5 题
-- SELECT emp_name FROM employees WHERE emp_name LIKE '%七%';

-- 第 6 题
-- SELECT d.dept_name, AVG(e.salary) AS avg_salary
-- FROM departments d
-- JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_name
-- ORDER BY avg_salary DESC;

-- 第 7 题
-- SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
-- FROM departments d
-- JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_name
-- HAVING emp_count > 2;

-- 第 8 题
-- SELECT COUNT(*) FROM employees WHERE hire_date > '2022-12-31';

-- 第 9 题
-- SELECT d.dept_name, SUM(e.salary) AS total_salary
-- FROM departments d
-- JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_name
-- HAVING total_salary > 30000;

-- 第 10 题
-- SELECT d.dept_name, MAX(e.salary) - MIN(e.salary) AS salary_gap
-- FROM departments d
-- JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_name;

-- 第 11 题
-- SELECT e.emp_name, p.project_name
-- FROM employees e
-- LEFT JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- LEFT JOIN projects p ON ep.project_id = p.project_id;

-- 第 12 题
-- SELECT e.emp_name, ep.role
-- FROM employees e
-- JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- JOIN projects p ON ep.project_id = p.project_id
-- WHERE p.project_name = '电商平台重构';

-- 第 13 题
-- SELECT e.emp_name, p.project_name, ep.role
-- FROM employees e
-- JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- JOIN projects p ON ep.project_id = p.project_id
-- WHERE p.budget > 100000;

-- 第 14 题
-- SELECT m.emp_name AS manager, s.emp_name AS subordinate
-- FROM employees s
-- JOIN employees m ON s.manager_id = m.emp_id;

-- 第 15 题
-- SELECT e.emp_name
-- FROM employees e
-- LEFT JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- WHERE ep.project_id IS NULL;

-- 第 16 题
-- SELECT emp_name, salary FROM employees
-- WHERE salary > (SELECT AVG(salary) FROM employees);

-- 第 17 题
-- SELECT e.emp_name, e.salary, e.dept_id
-- FROM employees e
-- WHERE e.salary > (
--     SELECT AVG(e2.salary) FROM employees e2 WHERE e2.dept_id = e.dept_id
-- );

-- 第 18 题
-- SELECT e.emp_name, COUNT(ep.project_id) AS project_count
-- FROM employees e
-- JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- GROUP BY e.emp_name
-- ORDER BY project_count DESC
-- LIMIT 1;

-- 第 19 题（窗口函数方法，MySQL 8.0+）
-- SELECT emp_name, dept_id, salary
-- FROM (
--     SELECT emp_name, dept_id, salary,
--            RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk
--     FROM employees
-- ) t WHERE rnk = 1;

-- 第 20 题
-- SELECT project_name, budget - (SELECT AVG(budget) FROM projects) AS over_budget
-- FROM projects
-- WHERE budget > (SELECT AVG(budget) FROM projects);

-- 第 21 题
-- SELECT emp_name, salary,
--        RANK() OVER (ORDER BY salary DESC) AS salary_rank
-- FROM employees;

-- 第 22 题
-- SELECT emp_name, dept_id, salary,
--        RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
-- FROM employees;

-- 第 23 题
-- WITH dept_avg AS (
--     SELECT d.dept_name, AVG(e.salary) AS avg_sal
--     FROM departments d
--     JOIN employees e ON d.dept_id = e.dept_id
--     GROUP BY d.dept_name
-- )
-- SELECT * FROM dept_avg ORDER BY avg_sal DESC LIMIT 1;

-- 第 24 题
-- SELECT emp_name, salary,
--     CASE
--         WHEN salary >= 20000 THEN '高薪'
--         WHEN salary >= 15000 THEN '中薪'
--         ELSE '低薪'
--     END AS salary_level
-- FROM employees;

-- 第 25 题
-- SELECT emp_name, dept_id, salary,
--        salary - AVG(salary) OVER (PARTITION BY dept_id) AS diff_from_avg
-- FROM employees;

-- 第 26 题
-- UPDATE employees
-- SET salary = salary * 1.1
-- WHERE dept_id = (SELECT dept_id FROM departments WHERE dept_name = '技术部');

-- 第 27 题（先确认）
-- SELECT e.emp_name FROM employees e
-- LEFT JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- WHERE ep.project_id IS NULL;
-- （确认后）
-- DELETE FROM employees
-- WHERE emp_id NOT IN (SELECT DISTINCT emp_id FROM employee_projects);

-- 第 28 题
-- INSERT INTO departments (dept_id, dept_name) VALUES (5, '法务部');
-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES (11, '陈新', 5, 17000, '2024-06-01', 9);

-- 第 29 题
-- WITH emp_proj_salary AS (
--     SELECT e.emp_name, p.project_name, e.salary,
--            RANK() OVER (PARTITION BY p.project_id ORDER BY e.salary DESC) AS rnk
--     FROM employees e
--     JOIN employee_projects ep ON e.emp_id = ep.emp_id
--     JOIN projects p ON ep.project_id = p.project_id
-- )
-- SELECT emp_name, project_name, salary
-- FROM emp_proj_salary WHERE rnk = 1;

-- 第 30 题
-- SELECT d.dept_name,
--        COUNT(e.emp_id)           AS emp_count,
--        ROUND(AVG(e.salary), 2)   AS avg_salary,
--        SUM(e.salary)             AS total_salary,
--        MAX(e.salary)             AS max_salary,
--        MIN(e.salary)             AS min_salary
-- FROM departments d
-- JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_name
-- ORDER BY total_salary DESC;
