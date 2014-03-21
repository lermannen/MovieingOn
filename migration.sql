CREATE TABLE crew (
	person_id integer REFERENCES persons (id),
	movie_id integer REFERENCES movies (id),
	job String
);

INSERT INTO crew (person_id, movie_id, job)
SELECT
	person_id, movie_id, "actor"
FROM actors;

INSERT INTO crew (person_id, movie_id, job)
SELECT
	person_id, movie_id, "director"
FROM directors;

INSERT INTO crew (person_id, movie_id, job)
SELECT
	person_id, movie_id, "producer"
FROM producers;

INSERT INTO crew (person_id, movie_id, job)
SELECT
	person_id, movie_id, "writer"
FROM writers;