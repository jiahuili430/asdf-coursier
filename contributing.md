# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test coursier https://github.com/jiahuili430/asdf-coursier.git "coursier --help"
```

Tests are automatically run in GitHub Actions on push and PR.
