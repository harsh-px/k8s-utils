
Below are example commands on how to build this:

```bash
$ docker build -t harshpx/docker-pgbench .
$ docker push harshpx/docker-pgbench
```

Use this container along with a postgres container which serves the database. Look for the hardcoded environment variables pointing to the database.

