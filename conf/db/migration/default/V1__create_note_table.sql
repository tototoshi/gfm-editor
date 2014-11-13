CREATE TABLE note (id serial primary key, title text not null, raw text not null);

CREATE TABLE twitter_account (
    id integer PRIMARY KEY,
    screen_name text NOT NULL,
    profile_image_url text NOT NULL
);
