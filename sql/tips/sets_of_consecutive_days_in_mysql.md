I was working on [Hacker Rank](https://www.hackerrank.com/) _Sql_ preparation  
and solved interesting topic on finding sets of consecutive days in MySQL.

I would like to leave a note on how I solved this problem.

* [What was my concept ?](#what-was-my-concept)
* [How transformed the data ?](#how-transformed-the-data)
* [The final query](#the-final-query)

## What was my concept ?

Given a schema and data, [project.sql](../projects.sql), I needed to find sets of consecutive days.
I wanted to take a simple approach by simply creating a groups of consecutive days.  
So I wanted a result set something like below.

```markdown
| id | task_id | start_date | end_date   | created_at          | group |
| -- | ------- | ---------- | ---------- | ------------------- | ----- |
|  1 |       1 | 2024-10-01 | 2024-10-02 | 2024-04-14 03:18:37 |    1 |
|  2 |       2 | 2024-10-02 | 2024-10-03 | 2024-04-14 03:18:37 |    1 |
|  3 |       3 | 2024-10-03 | 2024-10-04 | 2024-04-14 03:18:37 |    1 |
|  4 |       4 | 2024-10-10 | 2024-10-11 | 2024-04-14 03:18:37 |    2 |
|  5 |       5 | 2024-10-20 | 2024-10-21 | 2024-04-14 03:18:37 |    3 |
|  6 |       6 | 2024-10-21 | 2024-10-22 | 2024-04-14 03:18:37 |    3 |
```

## How transformed the data ?
What made this problem difficult was that there was hardly no relation between the _dates_ and the _group_.
So somehow **I had to find a way to group the dates in a way that I could find the consecutive days**.

The key for me was to co-relate the rows 
and find the difference in days of _end_date_ and _start_date_ use the [WINDOW function](https://dev.mysql.com/doc/refman/8.0/en/window-functions.html)

```sql
    IFNULL(
      DATEDIFF(start_date, LAG(end_date) OVER(ORDER BY start_date)), 0) AS diff
```

This gave me the difference in days between the _start_date_ and the _end_date_ of the previous row.

```plaintext
+---------+------------+------------+----+------+
| task_id | start_date | end_date   | rn | diff |
+---------+------------+------------+----+------+
|       1 | 2024-10-01 | 2024-10-02 |  1 |    0 |
|       2 | 2024-10-02 | 2024-10-03 |  2 |    0 |
|       3 | 2024-10-03 | 2024-10-04 |  3 |    0 |
|       4 | 2024-10-10 | 2024-10-11 |  4 |    6 |
|       5 | 2024-10-20 | 2024-10-21 |  5 |    9 |
|       6 | 2024-10-21 | 2024-10-22 |  6 |    0 |
+---------+------------+------------+----+------+
```

Next step was to create groups of consecutive days.  
For this, I used a recursive CTE to create groups of consecutive days. That is, iterate through the dataset and **if the difference in days is greater than 0**,  
increment the group number.

This will give me a sets of consecutive days.

```plaintext
+------+---------+------------+------------+------+
| Id   | Grp_Num | start_date | end_date   | diff |
+------+---------+------------+------------+------+
|    1 |       1 | 2024-10-01 | 2024-10-02 |    0 |
|    2 |       1 | 2024-10-01 | 2024-10-02 |    0 |
|    3 |       1 | 2024-10-02 | 2024-10-03 |    0 |
|    4 |       1 | 2024-10-03 | 2024-10-04 |    0 |
|    5 |       2 | 2024-10-10 | 2024-10-11 |    6 |
|    6 |       3 | 2024-10-20 | 2024-10-21 |    9 |
|    7 |       3 | 2024-10-21 | 2024-10-22 |    0 |
+------+---------+------------+------------+------+
7 rows in set (0.003 sec)
```

Finally, I could group the sets of consecutive days by the group number and find the minimum and maximum dates.

Gives a result as below,

```plaintext
+------------+------------+
| start_date | end_date   |
+------------+------------+
| 2024-10-10 | 2024-10-11 |
| 2024-10-20 | 2024-10-22 |
| 2024-10-01 | 2024-10-04 |
+------------+------------+
3 rows in set (0.003 sec)
```

## The final query

```sql
WITH RECURSIVE diffs AS (
  SELECT 
    start_date,
    end_date,
    ROW_NUMBER() OVER(ORDER BY start_date) AS Rn,
    IFNULL(
      DATEDIFF(start_date, LAG(end_date) OVER(ORDER BY start_date)), 0) AS diff
  FROM projects
), 
grps AS (
  SELECT
    1 AS Id,
    1 AS Grp_Num,
    start_date,
    end_date,
    diff
  FROM diffs WHERE rn = 1
  UNION ALL
  SELECT
    Id + 1,
    IF(diffs.diff > 0, Grp_Num + 1, Grp_Num),
    diffs.start_date AS start_date,
    diffs.end_date AS end_date,
    diffs.diff
  FROM grps INNER JOIN diffs ON grps.Id = diffs.Rn
)
SELECT 
  MIN(start_date) AS start_date,
  MAX(end_date) AS end_date
FROM grps
WHERE id > 1
GROUP BY Grp_Num
ORDER BY DATEDIFF(MAX(end_date), MIN(start_date)) ASC
;
```
