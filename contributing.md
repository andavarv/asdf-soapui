# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test soapui https://github.com/andavarv/asdf-soapui.git "soapui --version"
```

Tests are automatically run in GitHub Actions on push and PR.
