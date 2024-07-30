/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

select * from employee 
order by levels desc
limit 1

/* Q2: Which countries have the most Invoices? */

select billing_country ,count(*)from invoice
group by billing_country
order by count(*) desc
limit 1

/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by total desc
limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city ,sum(total)from invoice
group by billing_city 
order by sum(total) desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.first_name,c.last_name,sum(i.total) from customer as c join invoice as i on 
c.customer_id=i.customer_id
group by c.first_name,c.last_name
order by sum(i.total)desc
limit 1



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

select distinct c.first_name,c.last_name, c.email from customer as c join invoice as i 
on c.customer_id=i.customer_id join invoice_line as l on 
i.invoice_id=l.invoice_id join track as t on
l.track_id=t.track_id join genre as g on 
t.genre_id=g.genre_id
where g.name like 'Rock'
order by c.email asc



/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select * from artist
select a.name,count(t.track_id) from artist as a join
album as al on
a.artist_id=al.artist_id join track as t on 
al.album_id=t.album_id join
genre as g on 
t.genre_id=g.genre_id
where g.name like 'Rock'
group by  a.name
order by count(t.track_id) desc
limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds from track
where milliseconds> (select avg (milliseconds) from track)

order by milliseconds desc



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */


	with most_popular_genre as (
	select g.genre_id,count(l.unit_price*l.quantity),c.country,g.name,
	row_number()over(partition by c.country order by count(l.unit_price*l.quantity)desc) as row_no
	from customer as c join invoice as i on c.customer_id=i.customer_id join
	invoice_line as l on i.invoice_id=l.invoice_id join track as t on
	l.track_id=t.track_id join genre as g on 
	t.genre_id=g.genre_id
    group by 1,3,4
	order by 3 asc, 2 desc
	
)
select * from most_popular_genre where row_no<=1
		


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method : using CTE */

with table1 as (
	select c.customer_id,c.first_name,c.last_name,billing_country,sum(total),
	row_number()over(partition by billing_country order by sum(total) desc) as row_no
	from customer as c join invoice as i on
    c.customer_id=i.customer_id 
group by 1,2,3,4

	)

select * from table1 where row_no<=1

