# Gelinkt Notuleren

Backend systems and editor built on top of the Besluit and Mandaat model and application profile as defined on:
* http://data.vlaanderen.be/ns/besluit
* http://data.vlaanderen.be/doc/applicatieprofiel/besluit-publicatie/
* http://data.vlaanderen.be/ns/mandaat
* http://data.vlaanderen.be/doc/applicatieprofiel/mandatendatabank/

## What's included?

This repository harvest three setups.  The base of these setups resides in the standard docker-compose.yml.

* *docker-compose.yml* This provides you with the backend components.  There is a frontend application included which you can publish using a separate proxy (we tend to put a letsencrypt proxy in front).
* *docker-compose.dev.yml* Provides changes for a good frontend development setup.
  - publishes the backend services on port 80 directly, so you can run `ember serve --proxy http://localhost` when developing the frontend apps natively.
  - publishes the included frontend on port 83, so you can visit the app at http://localhost:83/
  - publishes the database instance on port 8890 so you can easily see what content is stored in the base triplestore
  - provides a mock-login backend service so you don't need the ACM/IDM integration.
* *docker-compose.demo.yml* Provides a setup for demo purposes.  It is similar to the dev setup, but publishes the frontend application directly:
  - publishes the frontend editor on port 80 so you can visit the app at http://localhost/
  - publishes the database instance on port 8890 so you can easily see what content is stored in the base triplestore
  - provides a mock-login backend service so you don't need the ACM/IDM integration

## Running and maintaining

General information on running and maintaining an installation

### How to setup the stack

First choose what you intend to run based on the description above.  Two scenario's are included here: the demo setup and the dev setup.

#### Running the demo setup

First install docker, docker-compose, and git-lfs (see https://github.com/git-lfs/git-lfs/wiki/Installation)

Execute the following:

    # Clone this repository
    git clone https://github.com/lblod/app-gelinkt-notuleren.git

    # Move into the directory
    cd app-gelinkt-notuleren

    # Make sure git-lfs is enabled after installation
    git lfs install

    # Start the system
    docker-compose -f docker-compose.yml -f docker-compose.demo.yml up -d

Wait for everything to boot to ensure clean caches.  You may choose to monitor the migrations service in a separate terminal to and wait for the overview of all migrations to appear: `docker-compose logs -f --tail=100 migrations`.

Once the migrations have ran, visit the application at http://localhost/mock-login

#### Running the dev setup

First install docker, docker-compose, and git-lfs (see https://github.com/git-lfs/git-lfs/wiki/Installation)

Execute the following:

    # Make sure git-lfs is enabled after installation
    git lfs install

    # Clone this repository
    git clone https://github.com/lblod/app-gelinkt-notuleren.git

    # Move into the directory
    cd app-gelinkt-notuleren

    # Start the system
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

Wait for everything to boot to ensure clean caches.  You may choose to monitor the migrations service in a separate terminal to and wait for the overview of all migrations to appear: `docker-compose logs -f --tail=100 migrations`.

Once the migrations have ran, you can start developing your application by connecting the ember frontend application to this backend.  See https://github.com/lblod/frontend-gelinkt-notuleren for more information on development with the ember application.

### Upgrading your setup

Once installed, you may desire to upgrade your current setup to follow development of the main stack.  The following example describes how to do this easily for both the demo setup, as well as for the dev setup.

#### Upgrading the demo setup

First we bring down the stack so we can upgrade things easily:

    # Move to the right directory
    cd place-where-you-clone-repository/app-gelinkt-notuleren

    # Bring the application down
    docker-compose -f docker-compose.yml -f docker-compose.demo.yml down

If you don't need the database of your current setup anymore, you may whish to remove its current contents.  Once we hit the first release, the migrations should take care of upgrading your application as needed, until then you may possibly hit a breaking change.

    # Remove all contents in the database folder
    rm -Rf data/db

    # Checkout the required files from the repository
    git checkout data/db

Next up is pulling in the changes from the upstream and launching the stack again.

    # Pull in the changes
    git pull origin master

    # Launch the stack
    docker-compose -f docker-compose.yml -f docker-compose.demo.yml up

As with the initial setup, we wait for everything to boot to ensure clean caches.  You may choose to monitor the migrations service in a separate terminal to and wait for the overview of all migrations to appear: `docker-compose logs -f --tail=100 migrations`.

Once the migrations have ran, visit the application at http://localhost/

#### Upgrading the dev setup

For the dev setup, we assume you'll pull more often and thus will most likely clear the database separately:

    # Bring the application down
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
    # Pull in the changes
    git pull origin master
    # Launch the stack
    docker-compose -f docker-compose.yml -f docker-compose.demo.yml up

As with the initial setup, we wait for everything to boot to ensure clean caches.  You may choose to monitor the migrations service in a separate terminal to and wait for the overview of all migrations to appear: `docker-compose logs -f --tail=100 migrations`.

Once the migrations have ran, you can go on with your current setup.

### Cleaning the database

At some times you may want to clean the database and make sure it's in a pristine state.  For development this is the following (for demo, replace the docker-compose.dev.yml with docker-compose.demo.yml):

    # Bring down our current setup
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
    # Keep only required database files
    rm -Rf data/db
    git checkout data/db
    # Bring the stack back up
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

Make sure to wait for the migrations to run.

### Loading a backup to the database
You might want to load a backup from a server as test data locally. First create backup like other stacks and put it in `data/db/backups`.  
Because the stack uses an old virtuoso version, loading a backup won't work by itself. Add the following configuration to your docker-compose file (`docker-compose.override.yml` would be a good place). The important part is overriding the image.
```
version: "3.4"
services:
  virtuoso:
    restart: "no"
    image: tenforce/virtuoso:latest
    environment:
      BACKUP_PREFIX: "virtuoso_backup_230101T1212-"
```

### Reports
This project includes the report dashboard. To make use of it, set a salt for the dashboard-login service in the docker-compose.override.yml and make sure to create a user running:
```
mu script project-scripts generate-dashboard-login
```

A report is generated each month, the historic report needs to be created manually. It can be triggered via curl:

```
curl -XPOST -H 'Content-Type: application/json' -d '{"data":{"attributes": {"reportName": "historicalReport"}}}' $IP_OF_REPORTS_SERVICE/reports

```

### External delta sync [EXPERIMENTAL]

*DISCLAIMER: this is not 100% bulletproof*

This feature allows syncing data from external applications, to be immediately reflected in the current application.
It is considered an external feature at this point and requires a manual setup.
The next steps assume you have never setup the sync before in this instance of the stack. Else you will need to run the re-import [TODO]

#### Step 1: Sync producer stacks with Gelinkt Notuleren

> **Prerequisites**:
> This setup makes use of [mu-cli](https://github.com/mu-semtech/mu-cli), so make sure to install it first.


To ensure both the producer and consumer work correctly, the respecting stacks should both start from the same base-state. By performing the following steps we can achieve this.

1. Download a data-dump from the producing service you wish to sync up with:
    - [Mandatendatabank (mdb)](https://mandaten.lokaalbestuur.vlaanderen.be)
    - [Leidinggevendendatabank (ldb)](https://leidinggevenden.lokaalbestuur.vlaanderen.be)
2. Place the data-dump file in the project root.
3. Run the provided mu-script to set-up the migrations we need:
   >  **Note:** if you want to learn more about mu-semtech migrations, consult [mu-migrations-service]( https://github.com/mu-semtech/mu-migrations-service)

   ```console
    foo@device:~project-root$ docker-compose up -d project-scripts # project-scripts container needs to be running
    foo@device:~project-root$ mu script project-scripts setup-data-sync-[mdb|ldb] data-dump.ttl
    ```
   You should be able to see that the following files have been generated in `./config/migrations`:
    - `<timestamp>-data-sync-[mdb|ldb]`
        - `<timestamp>-export.graph`
        - `<timestamp>-export.ttl` (should contain the data-export)
        - `<timestamp>-ingest-exported-triples.sparql`


4. Restart the migrations:
    ```console
    foo@device:~project-root$ docker-compose restart migrations
    ```
   Make sure the migrations ran successfully before continuing:
   
    ```console
    foo@device:~project-root$ docker-compose logs -f migrations

    migrations_1          | /data/migrations/20200929102725-data-sync-with-mdb/20200929102725-mdb-export.ttl [DONE]
    migrations_1          | /data/migrations/20200929102725-data-sync-with-mdb/20200929102726-ingest-mdb-triples.sparql [DONE]
    migrations_1          |
    migrations_1          | [2020-09-29 08:32:37] INFO  WEBrick 1.4.2
    migrations_1          | [2020-09-29 08:32:37] INFO  ruby 2.5.1 (2018-03-29) [x86_64-linux]
    migrations_1          | == Sinatra (v1.4.8) has taken the stage on 80 for production with backup from WEBrick
    migrations_1          | [2020-09-29 08:32:37] INFO  WEBrick::HTTPServer#start: pid=12 port=80
    ```
   > **Note**: This could take a while, so go grab yourself a coffee.

5. Restart the cache and resource services to make sure they are aware of the new data:
    ```console
    foo@device:~project-root$ docker-compose restart cache resource
    ```
6. (optional) remove the data-dump file in the project root.

#### Step 2: Setting up mandatarissen-consumer and functionarissen-consumer

1. Create/update the `docker-compose.override.yml` file with following lines:
   ```dockerfile
     mandatarissen-consumer:
       environment:
         SYNC_BASE_URL: 'https://mandaten.lokaalbestuur.vlaanderen.be' # the endpoint you want to sync from
         START_FROM_DELTA_TIMESTAMP: '2020-09-18T03:15:00.112Z' # a timestamp from TTL converted to ISO
     functionarissen-consumer:
       environment:
         SYNC_BASE_URL: 'https://leidinggevenden.lokaalbestuur.vlaanderen.be' # the endpoint you want to sync from
         START_FROM_DELTA_TIMESTAMP: '2020-09-18T03:15:00.112Z' # a timestamp from TTL converted to ISO
   ```

2. Include the `mandatarissen-consumer` container to the stack by including the provided `docker-compose.external-delta-sync.yml` to a `.env` file:
    ```text
    COMPOSE_FILE=docker-compose.yml:docker-compose.external-delta-sync.yml:docker-compose.override.yml
    ```
3. Update the stack:
    ```console
    foo@device:~project-root$ docker-compose up -d
    ```

## General application structure

This stack is built based on the mu.semte.ch architecture.  The starting point for this stack is [mu-project](https://github.com/mu-semtech/mu-project).

## API documentation

The vast amount of API space offered by this stack is covered by mu-cl-resources.  The OpenAPI documentation can be generated using [cl-resources-openapi-generator](https://github.com/mu-semtech/cl-resources-openapi-generator).  We also advise to checkout the [JSONAPI](https://jsonapi.org) documentation which covers the general way in which our APIs work and the [mu-cl-resources](https://github.com/mu-semtech/mu-cl-resources) documentation for specific extensions to this api.
