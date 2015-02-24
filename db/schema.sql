CREATE DATABASE forum;

CREATE TABLE posts (id serial primary key, title varchar(100), tagline varchar(255), link text, tag_id integer, votes integer, date_posted date default current_timestamp, total_comments integer);

CREATE TABLE comments (id serial primary key, post_id integer, body text, user_id varchar(50), date_posted date default current_timestamp);

CREATE TABLE tags (id serial primary key, tag_name varchar(50), description text);

CREATE TABLE users (id serial primary key, username varchar(50), first_name varchar(50), last_name varchar(50), email varchar(254), phone varchar(12), age integer, gender varchar(1), location varchar(255));

CREATE TABLE subscriptions (id serial primary key, full_name varchar(100), email varchar(254), phone varchar(12), tag_id integer);

