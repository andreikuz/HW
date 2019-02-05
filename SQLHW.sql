USE sakila;

SELECT * FROM actor;
-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name 
FROM actor;
# *1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT UPPER(CONCAT(first_name," ", last_name)) AS "actor_name" 
FROM actor;
# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name = "Joe";

# 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT  last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS Name_Count
FROM actor
GROUP BY last_name
HAVING Name_Count >= 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';


#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET first_name = 'GROUCHO'
WHERE first = 'HARPO'; 

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'address';

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON address.address_id; 

SELECT * FROM staff;

SELECT * FROM payment;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff_id, SUM(amount)
FROM payment
WHERE payment_date BETWEEN '20050731'  AND '20050901'
GROUP BY staff_id;

SELECT * FROM inventory;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join
SELECT title, COUNT(film_actor.actor_id) AS TotalActors
FROM film
JOIN film_actor ON film_actor.film_id = film.film_id
GROUP BY film.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(film_id)
FROM inventory
JOIN film 
USING(film_id)
WHERE film.title = 'Hunchback Impossible'
GROUP BY inventory.film_id;

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name.
SELECT last_name, SUM(amount)
FROM customer
JOIN payment ON customer.customer_id = payment.payment_id
GROUP BY last_name ORDER BY last_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title, film_id
FROM film
WHERE title LIKE 'K%' OR title LIKE  'Q%' AND 
language_id = (SELECT language_id FROM language WHERE name = 'English');


#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id FROM
film_actor WHERE film_id IN (SELECT film_id FROM film WHERE title = 'Alone Trip');

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email 
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id 
WHERE country_id = '20';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * FROM category;

#category 8 

SELECT * FROM film
WHERE film_id IN 
(SELECT film_id FROM film_category
WHERE category_id = '8');

#7e. Display the most frequently rented movies in descending order.

SELECT title,  COUNT(rental_id) AS MostFreq
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY MostFreq DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount)
FROM staff
JOIN payment
USING(staff_id)
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM staff s
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country ca ON c.country_id = ca.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) AS Gross
FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY name DESC;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top5Genre AS
SELECT name, SUM(amount) AS Gross
FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY name DESC
LIMIT 5;

#8b. How would you display the view that you created in 8a?

SELECT * FROM Top5Genre;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Top5Genre;