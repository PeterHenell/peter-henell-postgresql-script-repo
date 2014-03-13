create type AggregationLevel as enum  (
	'AVG','MIN','MAX'
);

create type AggregationMethod as enum  (
	'COUNT','WIN','BET'
);



create table GameStat(
	TimeSlot SMALLINT NOT NULL,
	GameId nvarchar(50) NOT NULL,
	Level  AggregationLevel NOT NULL,
	Method AggregationMethod NOT NULL,
	Value DECIMAL(19.6) NOT NULL)


/*
	Per game
	avg, min, max
	count, win, bet
	last hour, last 24 hour, last 10 minutes

*/	

SELECT * FROM heap_page_items(get_raw_page('cars'::text, 0));

SELECT  get_raw_page::text
FROM    get_raw_page('cars', 0);