-- ============================================================
-- 第二部分：练习题（题目）
-- ============================================================

-- ────────── Level 1: 基础查询 ──────────

-- 第 1 题：查询所有员工的姓名和工资
select emp_name, salary from employees;

-- 第 2 题：查询工资大于 15000 的员工姓名、部门和工资
select e.emp_name, d.dept_name, e.salary from employees e
left join departments d
on e.dept_id = d.dept_id
where e.salary > 15000;

-- 第 3 题：查询每个部门的员工人数
select d.dept_name, count(e.emp_id) as emp_count from employees e
join departments d
on e.dept_id = d.dept_id
group by (d.dept_name);

-- 第 4 题：查询工资最高的前 3 名员工
select e.emp_name from employees e
order by e.salary desc limit 3;

-- 第 5 题：查询姓名中包含"七"字的员工
select * from employees e
where e.emp_name like '%七%';

-- ────────── Level 2: 聚合与分组 ──────────

-- 第 6 题：查询每个部门的平均工资，按平均工资降序排列
select * from 
  (select d.dept_name, avg(e.salary) as dept_avg from departments d
    join employees e
    on d.dept_id = e.dept_id
    group by d.dept_name) t_avg
order by t_avg.dept_avg desc;

 SELECT d.dept_name, AVG(e.salary) AS dept_avg
  FROM departments d
  JOIN employees e ON d.dept_id = e.dept_id
  GROUP BY d.dept_name
  ORDER BY dept_avg DESC;

-- 第 7 题：查询员工人数大于 2 的部门名称和人数
SELECT d.dept_name, count(e.emp_id) AS dept_count
  FROM departments d
  JOIN employees e ON d.dept_id = e.dept_id
  GROUP BY d.dept_name
  HAVING dept_count > 2;

-- 第 8 题：查询 2022 年之后入职的员工总数
SELECT COUNT(*) FROM employees WHERE hire_date > '2022-12-31';

-- 第 9 题：查询每个部门的工资总和，只显示总和超过 30000 的部门
select d.dept_name, sum(e.salary) as dept_salary
  from departments d
  join employees e
  on d.dept_id = e.dept_id
  group by (d.dept_name)
  having dept_salary > 30000;

-- 第 10 题：查询各部门最高工资和最低工资的差值
select d.dept_name, (max(e.salary) - min(e.salary)) as d_value
  from departments d
  join employees e
  on d.dept_id = e.dept_id
  group by (d.dept_name);

-- ────────── Level 3: 多表连接 ──────────

-- 第 11 题：查询每个员工参与的项目名称（含未参与项目的员工）
select e.emp_name, p.project_name from employees e
left join employee_projects ep
on e.emp_id = ep.emp_id
left join projects p
on ep.project_id = p.project_id;

-- 第 12 题：查询参与了"电商平台重构"项目的所有员工姓名和角色
select e.emp_name, ep.role from employees e
join employee_projects ep
on e.emp_id = ep.emp_id
join projects p
on ep.project_id = p.project_id
where p.project_name = '电商平台重构';

-- 第 13 题：查询预算超过 100000 的项目中，每位员工的姓名、项目名和角色
select e.emp_name, p.project_name, ep.role from employees e
join employee_projects ep
on e.emp_id = ep.emp_id
join projects p
on ep.project_id = p.project_id
where p.budget > 100000;

-- 第 14 题：查询每位经理（有下级员工的人）及其直接下属的姓名
select m.emp_name as m_name, e.emp_name as name from employees m
join employees e
on m.emp_id = e.manager_id;

-- 第 15 题：查询没有参与任何项目的员工
select e.emp_name from employees e
left join employee_projects ep
on e.emp_id = ep.emp_id
left join projects p
on ep.project_id = p.project_id
where ep.project_id is null;

-- ────────── Level 4: 子查询 ──────────

-- 第 16 题：查询工资高于公司平均工资的员工
select * from employees e
where e.salary > (select avg(salary) from employees);

-- 第 17 题：查询工资高于其所在部门平均工资的员工
select * from employees e
join 
(select dept_id, avg(salary) as avg from employees group by dept_id) d
on e.dept_id = d.dept_id
where e.salary > d.avg;

-- 第 18 题：查询参与了项目最多的员工姓名和参与项目数
WITH project_count AS (
      SELECT e.emp_name, COUNT(ep.project_id) AS project_count,
             RANK() OVER (ORDER BY COUNT(ep.project_id) DESC) AS rnk
      FROM employees e
      JOIN employee_projects ep ON e.emp_id = ep.emp_id
      GROUP BY e.emp_name
  )
  SELECT emp_name, project_count
  FROM project_count
  WHERE rnk = 1;

-- 第 19 题：查询每个部门中工资最高的员工信息
with max_salary as (
  select e.dept_id, max(e.salary) as max_salary from employees e
  group by e.dept_id
)
select e.emp_name, e.salary from employees e
join max_salary ms
on e.dept_id = ms.dept_id
where e.salary = ms.max_salary;

-- 第 20 题：查询预算高于所有项目平均预算的项目，列出项目名和超出金额
select project_name, (budget - (select avg(budget) from projects)) as over_budget
from projects
where budget > (select avg(budget) from projects);


-- ────────── Level 5: 进阶（窗口函数 / CTE / CASE） ──────────

-- 第 21 题：用窗口函数给员工按工资排名（全公司排名）

select emp_name, salary, RANK() OVER (order by salary desc) as rank 
from employees; 

-- 第 22 题：用窗口函数在每个部门内按工资排名
select emp_name, 
  salary, 
  RANK() OVER (partition by dept_id order by salary desc) as dept_r
from employees; 

-- 第 23 题：用 CTE (WITH 子句) 查询平均工资最高的部门
with max_salary_dept as (
  select dept_id, avg(salary) as avg from employees
  group by dept_id
  order by avg desc
  limit 1
)
select * from departments d
join max_salary_dept msd
on d.dept_id = msd.dept_id;


-- 第 24 题：用 CASE 语句将员工按工资分为三档：高薪(>=20000)、中薪(15000-19999)、低薪(<15000)
select emp_name, salary,
  case
    when salary >= 20000 THEN '高新'
    when salary >= 15000 THEN '中薪'
    else '低薪'
  end as level
from employees;

-- 第 25 题：用窗口函数计算每位员工与其部门平均工资的差值
select emp_name, 
salary - (AVG(salary) OVER (PARTITION BY dept_id)) AS dept_avg
from employees;

-- ────────── Level 6: 数据修改 ──────────

-- 第 26 题：给技术部所有员工涨薪 10%

-- 第 27 题：删除没有参与任何项目的员工（请先用 SELECT 确认，再 DELETE）

-- 第 28 题：插入一个新部门"法务部"，并插入该部门一名新员工

-- ────────── Level 7: 综合挑战 ──────────

-- 第 29 题：查询每个项目中工资最高的员工姓名、项目名、工资
with max_salary as (select p.project_id, p.project_name, max(e.salary) as max_salary from employees e
join employee_projects ep
on e.emp_id = ep.emp_id
join projects p
on ep.project_id = p.project_id
group by p.project_id)

select e.emp_name, ms.project_name, e.salary from employees e
join employee_projects ep
on e.emp_id = ep.emp_id
join max_salary ms
on ep.project_id = ms.project_id
where e.salary = ms.max_salary;

-- 第 30 题：生成一份报表，列出：部门名、部门人数、部门平均工资、部门总工资、
--          部门最高薪、部门最低薪，按部门总工资降序排列

select 
  d.dept_name, 
  count(e.emp_id) as num_emp,
  avg(e.salary) as avg_salary,
  sum(e.salary) as sum_salary,
  max(e.salary) as max_salary,
  min(e.salary) as min_salary 
from departments d
join employees e
on d.dept_id = e.dept_id
group by d.dept_id
order by sum(e.salary) desc;
