# EITC Works data

# Setup
```bash
> createdb eitc
> psql -d eitc -c "CREATE EXTENSION postgis"
```

Install stuff using pip & [homebrew](http://brew.sh/)
```bash
> mkvirtualenv eitcworks
> pip install -r requirements.txt
> brew install gdal --with-postgresql
```

Mac users: you will also need the rename library

```bash
> brew install rename
```

Copy the config.mk.example to config.mk:

```bash
> cp config.mk.example config.mk
```

Configure make in `config.mk` with your DB settings, then:

```bash
> make all
```