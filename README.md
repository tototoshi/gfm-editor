# Github Flavored Markdown Editor

![](http://i.gyazo.com/ea6478b5ed506c86dac3af78270b9cfa.png)


## How to setup

```sql
$ createdb gfmeditor
$ psql -d gfmeditor -c 'CREATE TABLE note (id serial primary key, title text not null, raw text not null);'
```

```
$ virtualenv venv
$ . ./venv/bin/activate
$ make init
$ make build_asset
$ make run
```

## Keybind

|Key|Action|
|---|---|
|Esc|Focus on the search box|
|Enter|Focus on textarea|
|Delete|Delete a note|
|↓|Select previous note|
|↑|Select next note|
