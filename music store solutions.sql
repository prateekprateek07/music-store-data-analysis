create database music_store;
use music_store;

/*1.who is the senior most employee based on the job title*/

SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;


/*2.which countries have the most invoices?*/

SELECT 
    COUNT(invoice_id) AS total_invoice, billing_country
FROM
    invoice
GROUP BY 2
ORDER BY 2 DESC;

/* Q3: What are top 3 values of total invoice? */

SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT 
    SUM(total) AS total_invoices, billing_city
FROM
    invoice
GROUP BY 2
ORDER BY 2 DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total), 2) AS total_amount
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY 1 , 2 , 3
ORDER BY 4 DESC
LIMIT 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.*/

SELECT DISTINCT
    c.email, c.first_name, c.last_name
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line ii ON i.invoice_id = ii.invoice_id
        JOIN
    track t ON ii.track_id = t.track_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.name LIKE 'Rock'
ORDER BY 1;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT 
    a.name, COUNT(t.name)
FROM
    artist a
        JOIN
    album2 al ON a.artist_id = al.artist_id
        JOIN
    track t ON al.album_id = t.album_id
WHERE
    t.genre_id = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

(SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY 2 DESC);



/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

with mycte as 
(select a.artist_id as aa, a.name as an, round(sum(il.quantity * il.unit_price),2) as su from artist a join album2 al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id join invoice_line il on t.track_id = il.track_id
group by 1,2
order by 3 desc)
select c.customer_id, c.first_name, my.an, sum(il.quantity * il.unit_price) as total from customer c join invoice inc 
on c.customer_id = inc.customer_id
join invoice_line il on inc.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album2 al on t.album_id = al.album_id
join mycte my on al.artist_id = my.aa
group by 1,2,3
order by 4 desc;



/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */

with mycte as (select count(il.quantity) as quantity, c.country, g.name, g.genre_id , row_number() over (partition by c.country order by count(il.quantity) desc) as row_no from  customer c join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id join track t on il.track_id = t.track_id  
join genre g on t.genre_id = g.genre_id
group by 2,4,3)
select quantity from mycte where row_no = 1
order by 1 desc;


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

with mycte as (
select c.customer_id, c.country, sum(i.total) as total , row_number() over (partition by c.country order by sum(i.total) desc) as row_num
from customer c join invoice i on c.customer_id = i.customer_id 
group by 2,1
order by 1 desc)
select * from mycte where row_num = 1;

