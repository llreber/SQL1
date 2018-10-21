USE sakila;

-- 1a display first and last names
Select first_name, last_name 
FROM actor;

-- 1b display first and last names in new column
ALTER TABLE actor
ADD COLUMN actor_name VARCHAR(50) AS (CONCAT(first_name," ", last_name));

Select *
FROM actor;

-- 2a select actors names "joe"
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "JOE";

-- 2b select actors with "GEN" in last names
SELECT *
FROM actor
WHERE locate("GEN", last_name);

-- 2c select actors with "LI" in last names and sort by last name, first name
SELECT *
FROM actor
WHERE locate("LI", last_name)
ORDER BY last_name, first_name;

-- 2d select countries
SELECT *
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a Add description column
ALTER TABLE actor 
ADD description BLOB;

SELECT *
FROM actor;
-- 3b delete description column
ALTER TABLE actor 
DROP COLUMN description;

SELECT *
FROM actor;
-- 4a list actors by last name
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

-- 4b last names shared by more that 2 actors
SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c change Harpo to Groucho
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name =  "HARPO"
WHERE First_name =  "GROUCHO" AND last_name = "WILLIAMS";

SELECT *
FROM actor
WHERE last_name = "WILLIAMS";

-- 4d change Groucho back to Harpo
UPDATE actor SET first_name =  "GROUCHO"
WHERE First_name =  "HARPO" AND last_name = "WILLIAMS";

SELECT *
FROM actor
WHERE last_name = "WILLIAMS";
SET SQL_SAFE_UPDATES = 1;

-- 5a locate schema of address table and re-create table
SHOW CREATE TABLE address;

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a display first and last names and address of staff members
SELECT first_name, last_name, address
FROM staff s
JOIN payment p
ON s.address_id = a.address_id;

-- 6b total amount rung up in Aug 2005
SELECT first_name, last_name, sum(amount)
FROM staff s
JOIN payment p
ON s.staff_id = p.staff_id
WHERE payment_date >= '2005-08-01' AND payment_date < '2005-09-01'
GROUP BY s.staff_id;

-- 6c list each film and the number of actors
SELECT title, count(actor_id) as "Number of Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;

-- 6d how many copies of "Hunchback Impossible" exist in inventory system?
SELECT COUNT(inventory_id)
FROM inventory i
JOIN film f 
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- 6e total amount paid by customer
SELECT first_name, last_name, sum(amount) AS "Amount Paid"
FROM payment p 
JOIN customer c 
ON p.customer_id = c.customer_id
GROUP BY last_name, first_name
ORDER BY last_name, first_name;

-- 7a list movies starting with K and Q in English
SELECT title
FROM film f
JOIN language l
ON l.language_id = f.language_id
WHERE (title LIKE "K%" OR title LIKE "Q%") AND l.name = "English";

-- 7b use subqueries to show actors in "Alone Trip"
SELECT first_name, last_name
FROM actor a 
JOIN film_actor fa
ON fa.actor_id = a.actor_id
WHERE film_id = 
	(SELECT film_id
	FROM film
	WHERE title = "Alone Trip"
	);
    
-- 7c names and addresses of Canadian customers
SELECT first_name, last_name, address, postal_code, city, country
FROM customer c
JOIN address a 
	ON c.address_id = a.address_id
JOIN city
	ON a.city_id = city.city_id
JOIN country
	ON city.country_id = country.country_id
WHERE country = "Canada";
  
-- 7d Identify all movies categorized as family films.
SELECT title
FROM film f
JOIN film_category fc
	ON f.film_id = fc.film_id
JOIN category c
	ON c.category_id = fc.category_id
WHERE c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order
SELECT title, COUNT(title) AS "Times_Rented"
FROM film f
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON r.inventory_id = i.inventory_id
GROUP BY title
ORDER BY Times_Rented DESC;

-- 7f. display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS "Revenue"
FROM store s
JOIN inventory i
	ON s.store_id = i.store_id
JOIN rental r
	ON r.inventory_id = i.inventory_id
JOIN payment p
	ON r.rental_id = p.rental_id
GROUP BY s.store_id;
    
-- 7g. display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store s
JOIN address a
	ON s.address_id = a.address_id
JOIN city c 
	ON c.city_id = a.city_id
JOIN country cy
	ON cy.country_id = c.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order. 
SELECT c.name, sum(amount) AS "Total Revenue"
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN inventory i
	ON i.film_id = fc.film_id
JOIN rental r 
	ON r.inventory_id = i.inventory_id
JOIN payment p 
	ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY sum(amount) DESC
LIMIT 5;

-- 8a.  Use the solution from the problem above to create a view. 
CREATE VIEW top_five_genres AS
SELECT c.name, sum(amount) AS "Total Revenue"
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN inventory i
	ON i.film_id = fc.film_id
JOIN rental r 
	ON r.inventory_id = i.inventory_id
JOIN payment p 
	ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY sum(amount) DESC
LIMIT 5;

-- 8b. display the view that you created in 8a
SELECT * FROM top_five_genres;

-- 8c You find that you no longer need the view top_five_genres. Write a query to delete it
DROP VIEW total_sales;