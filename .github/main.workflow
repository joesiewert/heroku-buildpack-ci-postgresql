workflow "Build PG Versions for Supported Stacks" {
  on = "release"
  resolves = ["PG 11.1", "Heroku-18 Build"]
}

action "Heroku-18 Build" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  args = "build -t postgresql-builder-$STACK-$GITHUB_SHA:latest --build-arg STACK_FOLDER=\"$STACK\" --build-arg BASE_STACK=\"heroku/$(echo \"$STACK\" | sed \"s/-/:/1\")\""
  env = {
    STACK = "heroku-18"
  }
}

action "PG 11.1" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  args = "run -e \"S3_BUCKET=$S3_BUCKET\" -e \"POSTGRESQL_VERSION=$PGSQL_VERSION\" -e \"AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\" -e \"AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\" -a=stdout -a=stderr postgresql-builder-$STACK-$GITHUB_SHA:latest"
  needs = ["Heroku-18 Build"]
  env = {
    S3_BUCKET = "ci-database-binary"
    PGSQL_VERSION = "11.1"
  }
}
