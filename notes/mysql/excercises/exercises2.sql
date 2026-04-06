-- ============================================================
-- 窗口函数专项练习题 (MySQL 8.0+)
-- ============================================================
-- 基于 sqlstudy 数据库的 employees / departments / projects / employee_projects 表
-- 需先执行 exercises.sql 建表插数据
-- ============================================================

-- 前置数据准备（确保原始数据存在）
-- source /Users/douchuan/work/tmp/sqlstudy/exercises.sql;

-- ============================================================
-- 第 1 题：全公司工资排名（用 RANK）
-- 输出：emp_name, salary, 排名
-- 提示：相同工资应该同名次
-- ============================================================
select emp_name, RANK() OVER(order by salary desc) as rk
from employees
order by salary desc;


-- 第 2 题：全公司工资排名（用 DENSE_RANK vs ROW_NUMBER）
-- 分别用 RANK、DENSE_RANK、ROW_NUMBER 给员工排工资名次
-- 输出：emp_name, salary, rnk, dense_rnk, row_num
-- 思考：三个排名函数有什么区别？
-- ============================================================
select emp_name, salary, 
  RANK() OVER(order by salary desc) as rk,
  DENSE_RANK() OVER(order by salary desc) as dense_rk,
  ROW_NUMBER() OVER(order by salary desc) as row_num
from employees
order by salary desc;


-- 第 3 题：部门内工资排名
-- 输出：dept_name, emp_name, salary, 部门内排名
-- 提示：PARTITION BY 部门
-- ============================================================
select
  e.emp_name,
  d.dept_name,
  RANK() OVER(PARTITION BY e.dept_id order by e.salary desc ) as rk
from employees e
join departments d
on e.dept_id = d.dept_id;

-- 第 4 题：累计工资
-- 按 emp_id 顺序，输出每位员工的姓名、工资、截至当前员工的累计工资
-- 输出：emp_id, emp_name, salary, running_total
-- 提示：SUM() OVER (ORDER BY emp_id)
-- ============================================================
select
  emp_id, emp_name, salary,
  SUM(salary) OVER(order by emp_id) as running_total
from employees;

-- 第 5 题：部门累计工资
-- 在每个部门内，按 emp_id 顺序累计工资
-- 输出：dept_name, emp_name, salary, dept_running_total
-- ============================================================
select
  e.emp_name, e.salary, d.dept_name,
  SUM(e.salary) OVER(PARTITION BY e.dept_id order by e.emp_id) as running_total
from employees e
join departments d
on e.dept_id = d.dept_id;

-- 第 6 题：部门平均工资（窗口函数版）
-- 每位员工旁边显示其所在部门的平均工资
-- 输出：emp_name, dept_name, salary, dept_avg_salary
-- 提示：AVG() OVER (PARTITION BY ...)
-- ============================================================

-- 第 7 题：员工工资与部门平均工资的差距
-- 输出：emp_name, dept_name, salary, dept_avg_salary, diff
-- 提示：基于第 6 题的结果
-- ============================================================

-- 第 8 题：Lag 函数 — 每位员工与同部门上一名员工的工资差
-- 同部门内按 emp_id 排序，计算与上一名员工的工资差值
-- 输出：dept_name, emp_name, salary, prev_salary, diff
-- 提示：LAG(salary) OVER (PARTITION BY dept_id ORDER BY emp_id)
-- ============================================================

-- 第 9 题：Lead 函数 — 每位员工与同部门下一名员工的工资差
-- 输出：dept_name, emp_name, salary, next_salary, diff
-- ============================================================

-- 第 10 题：移动平均
-- 按 emp_id 顺序，计算每位员工与其前 1 名员工（共 2 人）的平均工资
-- 输出：emp_id, emp_name, salary, moving_avg
-- 提示：ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
-- ============================================================

-- 第 11 题：FIRST_VALUE / LAST_VALUE
-- 在每个部门内，找出工资最高和最低的员工姓名
-- 输出：dept_name, emp_name, salary, dept_max_salary, dept_min_salary,
--       highest_paid, lowest_paid
-- 提示：LAST_VALUE 需要指定窗口帧
-- ============================================================

-- 第 12 题：NTILE — 将全公司员工按工资均分为 3 组
-- 输出：emp_name, salary, salary_group (1/2/3)
-- 提示：NTILE(3) OVER (ORDER BY salary DESC)
-- ============================================================

-- 第 13 题：每个项目内工资排名
-- 输出：project_name, emp_name, role, salary, project_rank
-- 提示：需要 JOIN 三张表，RANK() OVER (PARTITION BY project_id ...)
-- ============================================================

-- 第 14 题：各部门人数统计（窗口函数版）
-- 不使用 GROUP BY，用窗口函数统计每个部门的员工人数
-- 输出：emp_name, dept_name, salary, dept_emp_count
-- 提示：COUNT() OVER (PARTITION BY dept_id)
-- ============================================================

-- 第 15 题：综合 — 找出每个部门工资排名前 2 的员工
-- 输出：dept_name, emp_name, salary, dept_rank
-- 提示：CTE + 窗口函数 + 过滤
-- ============================================================

-- ============================================================
-- 参考答案
-- ============================================================

-- 第 1 题
-- SELECT emp_name, salary,
--        RANK() OVER (ORDER BY salary DESC) AS rnk
-- FROM employees;

-- 第 2 题
-- SELECT emp_name, salary,
--        RANK()       OVER (ORDER BY salary DESC) AS rnk,
--        DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk,
--        ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
-- FROM employees;
-- 区别：
--   RANK       : 并列同名次，跳号 (1,1,3)
--   DENSE_RANK : 并列同名次，不跳号 (1,1,2)
--   ROW_NUMBER : 强制不同名次 (1,2,3)

-- 第 3 题
-- SELECT d.dept_name, e.emp_name, e.salary,
--        RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS dept_rank
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;

-- 第 4 题
-- SELECT emp_id, emp_name, salary,
--        SUM(salary) OVER (ORDER BY emp_id) AS running_total
-- FROM employees;

-- 第 5 题
-- SELECT d.dept_name, e.emp_name, e.salary,
--        SUM(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.emp_id) AS dept_running_total
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;

-- 第 6 题
-- SELECT e.emp_name, d.dept_name, e.salary,
--        ROUND(AVG(e.salary) OVER (PARTITION BY e.dept_id), 2) AS dept_avg_salary
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;

-- 第 7 题
-- SELECT emp_name, dept_name, salary,
--        ROUND(AVG(salary) OVER (PARTITION BY dept_id), 2) AS dept_avg_salary,
--        salary - AVG(salary) OVER (PARTITION BY dept_id) AS diff
-- FROM employees;

-- 第 8 题
-- SELECT d.dept_name, e.emp_name, e.salary,
--        LAG(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.emp_id) AS prev_salary,
--        e.salary - LAG(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.emp_id) AS diff
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;

-- 第 9 题
-- SELECT d.dept_name, e.emp_name, e.salary,
--        LEAD(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.emp_id) AS next_salary,
--        LEAD(e.salary) OVER (PARTITION BY e.dept_id ORDER BY e.emp_id) - e.salary AS diff
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;

-- 第 10 题
-- SELECT emp_id, emp_name, salary,
--        ROUND(AVG(salary) OVER (ORDER BY emp_id ROWS BETWEEN 1 PRECEDING AND CURRENT ROW), 2) AS moving_avg
-- FROM employees;

-- 第 11 题
-- SELECT d.dept_name, e.emp_name, e.salary,
--        MAX(e.salary) OVER (PARTITION BY e.dept_id) AS dept_max_salary,
--        MIN(e.salary) OVER (PARTITION BY e.dept_id) AS dept_min_salary,
--        FIRST_VALUE(e.emp_name) OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC
--            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS highest_paid,
--        LAST_VALUE(e.emp_name) OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC
--            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_paid
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;
-- 注意：FIRST_VALUE / LAST_VALUE 的窗口帧默认是 RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- 所以 LAST_VALUE 必须显式指定 UNBOUNDED FOLLOWING，否则只看到当前行

-- 第 12 题
-- SELECT emp_name, salary,
--        NTILE(3) OVER (ORDER BY salary DESC) AS salary_group
-- FROM employees;

-- 第 13 题
-- SELECT p.project_name, e.emp_name, ep.role, e.salary,
--        RANK() OVER (PARTITION BY p.project_id ORDER BY e.salary DESC) AS project_rank
-- FROM employees e
-- JOIN employee_projects ep ON e.emp_id = ep.emp_id
-- JOIN projects p ON ep.project_id = p.project_id;

-- 第 14 题
-- SELECT e.emp_name, d.dept_name, e.salary,
--        COUNT(e.emp_id) OVER (PARTITION BY e.dept_id) AS dept_emp_count
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id;

-- 第 15 题
-- WITH ranked AS (
--     SELECT d.dept_name, e.emp_name, e.salary,
--            RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS dept_rank
--     FROM employees e
--     JOIN departments d ON e.dept_id = d.dept_id
-- )
-- SELECT * FROM ranked WHERE dept_rank <= 2;
