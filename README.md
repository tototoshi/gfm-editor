# Github Flavored Markdown Editor

![](http://i.gyazo.com/20e46477743b9afdb4c38da69329d498.png)


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
|↓|Select next note|
|↑|Select previous note|
|⌘→|Hide preview|
|⌘←|Show preview|
