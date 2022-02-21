/*We want to reward our users who have been around the longest.  
Find the 5 oldest users.*/
SELECT 
    *
FROM
    users
ORDER BY DATE(created_at) ASC
LIMIT 5;

/*What day of the week do most users register on?
We need to figure out when to schedule an ad campgain*/
SELECT 
    COUNT(*) AS user_count, DAYNAME(created_at) AS Day_of_week
FROM
    users
GROUP BY Day_of_week
ORDER BY user_count DESC;

/*method 2*/
SELECT 
    DATE_FORMAT(created_at, '%W') AS 'day of the week',
    COUNT(*) AS 'total registration'
FROM
    users
GROUP BY 1
ORDER BY 2 DESC;


/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/
SELECT 
    U.username, U.id AS user_id, P.id AS photo_id
FROM
    users AS U
        LEFT JOIN
    photos AS P ON P.user_id = U.id
WHERE
    P.id IS NULL;

/*method 2*/
SELECT 
    username
FROM
    users
        LEFT JOIN
    photos ON users.id = photos.user_id
WHERE
    photos.id IS NULL;

/*We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/

SELECT 
    U.username, L.photo_id, COUNT(L.user_id) AS total_likes
FROM
    likes AS L
        JOIN
    photos AS P ON L.photo_id = P.id
        JOIN
    users AS U ON U.id = P.user_id
GROUP BY 2
ORDER BY total_likes DESC
LIMIT 1;

/*method 2*/
SELECT 
    username,
    photos.id,
    photos.image_url,
    COUNT(photos.id) AS total
FROM
    photos
        INNER JOIN
    likes ON likes.photo_id = photos.id
        INNER JOIN
    users ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total DESC
LIMIT 1;


/*Our Investors want to know...
How many times does the average user post?*/
SELECT 
    ROUND((SELECT 
                    COUNT(*)
                FROM
                    photos) / (SELECT 
                    COUNT(*)
                FROM
                    users),
            2);

/*user ranking by postings higher to lower*/
SELECT 
    username, users.id, COUNT(photos.id) AS postings
FROM
    users
        LEFT JOIN
    photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY postings DESC;


SELECT 
    users.username, COUNT(photos.image_url)
FROM
    users
        JOIN
    photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY 2 DESC;

/*total numbers of users who have posted at least one time */
SELECT 
    username, COUNT(*) AS postings
FROM
    users
        LEFT JOIN
    photos ON users.id = photos.user_id
GROUP BY users.id
HAVING postings = 1;


/*version 2*/
SELECT 
    COUNT(DISTINCT (users.id)) AS total_number_of_users_with_posts
FROM
    users
        JOIN
    photos ON users.id = photos.user_id;

SELECT 
    *
FROM
    photos
WHERE
    user_id = 6;

/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/
SELECT 
    COUNT(tag_id) AS top_tags, t.tag_name
FROM
    photo_tags AS pt
        LEFT JOIN
    tags AS t ON pt.tag_id = t.id
GROUP BY pt.tag_id
ORDER BY top_tags DESC
LIMIT 5;

SELECT 
    *
FROM
    comments;
/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/

SELECT 
    u.id, u.username, COUNT(u.id) AS total_likes
FROM
    users AS u
        LEFT JOIN
    likes AS l ON u.id = l.user_id
GROUP BY u.id
HAVING total_likes = (SELECT 
        COUNT(*)
    FROM
        photos)
ORDER BY u.id;


/*We also have a problem with celebrities
Find users who have never commented on a photo*/
SELECT 
    u.id, u.username, COUNT(c.id) AS no_comments
FROM
    users AS u
        LEFT JOIN
    comments AS c ON u.id = c.user_id
GROUP BY u.id
HAVING no_comments = 0;

/*version 2*/
SELECT DISTINCT
    (u.id), u.username
FROM
    users AS u
        LEFT JOIN
    comments AS c ON u.id = c.user_id
WHERE
    comment_text IS NULL;


/*Mega Challenges
Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/
SELECT 
    table_a.total_a AS no_comments_by_users, 
    (table_a.total_a / (SELECT COUNT(*) FROM users)) * 100 AS '%',
    table_b.total_b AS every_comments_by_users,
    (table_b.total_b / (SELECT COUNT(*) FROM users)) * 100 AS '%'
FROM
 (
    SELECT COUNT(*) AS total_a
    FROM 
		(SELECT DISTINCT (u.id), u.username
    FROM users AS u
    LEFT JOIN comments AS c ON u.id = c.user_id
    WHERE comment_text IS NULL) AS total_number_of_users_without_comments)
    as table_a
    JOIN
    (
	SELECT COUNT(*) AS total_b
    FROM
        (SELECT u.id, u.username, COUNT(u.id) AS total_comments
    FROM
        users AS u
    LEFT JOIN comments AS c ON u.id = c.user_id
    GROUP BY u.id
    HAVING total_comments = (SELECT COUNT(*) FROM photos)) as total_comments)
    AS table_b;
    
   
/*Find users who have ever commented on a photo*/

SELECT DISTINCT (u.id), u.username 
FROM users AS u 
LEFT JOIN comments AS c ON u.id = c.user_id 
WHERE comment_text IS Not NULL;

/*Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on photos before*/
SELECT 
    table_a.total_a AS no_comments_by_users, 
    (table_a.total_a / (SELECT COUNT(*) FROM users)) * 100 AS '%',
    table_b.total_b AS any_comments_by_users,
    (table_b.total_b / (SELECT COUNT(*) FROM users)) * 100 AS '%'
FROM
 (
    SELECT COUNT(*) AS total_a
    FROM 
		(SELECT DISTINCT (u.id), u.username
    FROM users AS u
    LEFT JOIN comments AS c ON u.id = c.user_id
    WHERE comment_text IS NULL) AS total_number_of_users_without_comments)
    as table_a
    JOIN
    (
	SELECT COUNT(*) AS total_b
    FROM
        (SELECT DISTINCT (u.id), u.username 
		FROM users AS u 
		LEFT JOIN comments AS c ON u.id = c.user_id 
		WHERE comment_text IS Not NULL) as any_comments)
    AS table_b;
    
