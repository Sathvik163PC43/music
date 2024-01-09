create database sql_project1;
use sql_project1;
create table employee(employee_id int primary key ,last_name text, first_name text,title text,reports_to double default 0 , levels text , 
birthdate text,hiredate text,address text,city text,state text,country text,postal_code text, phone char(17),facts text,email text);

create table customer(customer_id int primary key,first_name text,last_name text,company text,address text,city text,state text,
country text,postal_code text,phone text,facts text,email text,support_rep_id int,foreign key(support_rep_id) 
references employee(employee_id) on update cascade on delete cascade);

create table invoice(invoice_id int primary key ,customer_id int ,invoice_date text,billing_address text, billing_city text,
billing_state text,billing_country text,billing_postal_code text,total double,foreign key(customer_id) 
references customer(customer_id) on update cascade on delete cascade);
 

 
create table artist(artist_id int primary key,name text);

create table album(album_id int primary key,title text,artist_id int,
foreign key(artist_id) references artist(artist_id) on update cascade on delete cascade);

create table media_type(media_type_id int primary key,name text);

create table genre(genre_id int primary key, name text);

create table track(track_id int primary key,name text,album_id int,media_type_id int,genre_id int,composer text,
milliseconds bigint,bytes bigint,unit_price double,
 foreign key(album_id) references album(album_id) on update cascade on delete cascade,
 foreign key(media_type_id) references media_type(media_type_id) on update cascade on delete cascade,
 foreign key(genre_id) references genre(genre_id) on update cascade on delete cascade);
 
 
create table playlist(playlist_id int primary key,name text);




create table playlist_track(playlist_id int,track_id int,
foreign key(playlist_id) references playlist(playlist_id) on update cascade on delete cascade,
foreign key(track_id) references track(track_id) on update cascade on delete cascade);

create table invoice_line(invoice_line_id int primary key, invoice_id int,track_id int,foreign key (track_id) references track(track_id)
,unit_price double,quantity int, foreign key(invoice_id) references invoice(invoice_id) on update cascade on delete cascade);

select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

# question 1
SELECT levels, last_name, first_name,hiredate,title
FROM employee
ORDER BY levels DESC
LIMIT 1;

# Question 2
SELECT billing_country, COUNT(*) AS numberofinvoices
FROM invoice
GROUP BY billing_country
ORDER BY numberofinvoices desc;

# Question 3
select * from invoice order by total desc limit 3;


# Question 4 
SELECT billing_city AS billingCity,
       SUM(Total)  AS invoices
  FROM invoice
GROUP BY billing_city
ORDER BY invoices DESC;


# Question 5
SELECT customer_id AS customerId,
       SUM(total) AS money_spent 
  FROM invoice
GROUP BY customer_id 
ORDER BY money_spent DESC 
 LIMIT 1;
 
 # Question 6
 SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

# Question 7 
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;
 
 # Question 8
SELECT trk.name, trk.milliseconds
FROM track trk
WHERE trk.milliseconds > 	( 	SELECT AVG(milliseconds) 
								FROM  track)
ORDER BY trk.milliseconds desc;

# Question - 9
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

# Question - 10
WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;



# Question 11
WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;