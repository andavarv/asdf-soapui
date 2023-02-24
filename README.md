<div align="center">

# asdf-soapui [![Build](https://github.com/andavarv/asdf-soapui/actions/workflows/build.yml/badge.svg)](https://github.com/andavarv/asdf-soapui/actions/workflows/build.yml) [![Lint](https://github.com/andavarv/asdf-soapui/actions/workflows/lint.yml/badge.svg)](https://github.com/andavarv/asdf-soapui/actions/workflows/lint.yml)


[soapui](https://github.com/andavarv/soapui) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add soapui
# or
asdf plugin add soapui https://github.com/andavarv/asdf-soapui.git
```

soapui:

```shell
# Show all installable versions
asdf list-all soapui

# Install specific version
asdf install soapui latest

# Set a version globally (on your ~/.tool-versions file)
asdf global soapui latest

# Now soapui commands are available
soapui --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/andavarv/asdf-soapui/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Andavar Veeramalai](https://github.com/andavarv/)
