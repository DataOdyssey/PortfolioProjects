--Q1 : Who is the senior most employee based on job title?

select top 1 * from employee
order by levels desc


--Q2 : Which countries have the most Invoices?

select *  from invoice

select count(*) as total_invoices, billing_country
from invoice
group by billing_country
order by total_invoices desc


--Q3 : What are top 3 values of total invoice?

select top 3 total from invoice
order by total desc


/*Q4 : Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
	   Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.*/

select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc


/*Q5 : Who is the best customer? The customer who has spent the most money will be declared the best customer. 
	   Write a query that returns the person who has spent the most money.*/


select * from customer
select * from invoice

select customer.customer_id, customer.first_name,  customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name 
order by total desc


/* Q6 : Write a query to return the email, first name, lastname and genre of all Rock Music Listeners.
	   Return your list ordered alphabetically by email starting with A*/

-- Method 1 :-

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track$ on invoice_line.track$_id = track$.track$_id  
join genre on track$.genre_id = genre.genre_id
where genre.genre_id = 1
order by email

--Method 2 :-

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	select track_id from track$
	join genre on track$.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email


/* Q7 : Let's invite the artists who have written the most rock music in our dataset.
	    Write a query that returns the Artist name and total track$ count of the top 10 rock bands.*/


select * from artist

select top 10 artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from artist
join album on artist.artist_id = album.artist_id
join track$ on album.album_id = track$.album_id
join genre on track$.genre_id = genre.genre_id
where genre.genre_id = 1
group by artist.artist_id, artist.name
order by number_of_songs desc


/* Q8 : Return all the track$ names that have a song length longer than the average song length. 
		Return the Name and Milliseconds for each track$. 
	    Order by the song length with the longest songs listed first.*/


select name, milliseconds
from track$
where milliseconds > (
		select avg(track$.milliseconds) as avg_track$_length 
		from track$)
order by milliseconds desc


/* Q9 : Find how much amount spent by each customer on artists ? 
		Write a query to return customer name, artist name and total spent*/


with best_selling_artist (artist_id, name, total_sales)
as
(
select top 1 artist.artist_id, artist.name, sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from artist
join album on artist.artist_id = album.artist_id
join track$ on album.album_id = track$.album_id
join invoice_line on track$.track_id = invoice_line.track_id
group by artist.artist_id, artist.name
order by total_sales desc
)
select customer.customer_id,customer.first_name, customer.last_name, best_selling_artist.name, 
sum(invoice_line.unit_price * invoice_line.quantity) as total_amount_spent
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track$ on invoice_line.track_id = track$.track_id
join album on track$.album_id = album.album_id
join best_selling_artist on album.artist_id = best_selling_artist.artist_id
group by customer.customer_id,customer.first_name, customer.last_name, best_selling_artist.name
order by total_amount_spent desc


/* Q10 : We want to find out the most popular music Genre for each country.
		 Determine the most popular Genre as the genre with highest amount of purchases.
		 Write a query that returns each country along with the top Genre. 
		 For countries where the maximum number of purchases is shared return all Genres.*/


with popular_genre (purchases, country, name, genre_id, RowNo)
as
(
select top 100 count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track$ on invoice_line.track_id = track$.track_id
join genre on track$.genre_id = genre.genre_id
group by customer.country, genre.name, genre.genre_id
order by customer.country asc, purchases desc
)
select * from popular_genre where RowNo <= 1


/* Q11 : Write a query that determines the customer that has spent the most on music for each country.
		 Write a query that returns the country along with the top customer and how much they spent. 
		 For countries where the top amount spent is shared, provide all customers who spent this amount. */


with customer_with_country (customer_id, first_name, last_name, billing_country, total_spending)
as
(
select top 59 customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
from invoice
join customer on customer.customer_id = invoice.invoice_id
group by customer.customer_id, first_name, last_name, billing_country
order by customer.customer_id, total_spending desc
)
,
country_max_spending (billing_country, max_spending)
as
(
select billing_country, max(total_spending) as max_spending  
from customer_with_country
group by billing_country
)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1
