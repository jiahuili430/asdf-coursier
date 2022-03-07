<div align="center">

# asdf-coursier [![Build](https://github.com/jiahuili430/asdf-coursier/actions/workflows/build.yml/badge.svg)](https://github.com/jiahuili430/asdf-coursier/actions/workflows/build.yml) [![Lint](https://github.com/jiahuili430/asdf-coursier/actions/workflows/lint.yml/badge.svg)](https://github.com/jiahuili430/asdf-coursier/actions/workflows/lint.yml)


[coursier](https://get-coursier.io/docs/overview) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add coursier
# or
asdf plugin add coursier https://github.com/jiahuili430/asdf-coursier.git
```

coursier:

```shell
# Show all installable versions
asdf list-all coursier

# Install specific version
asdf install coursier latest

# Set a version globally (on your ~/.tool-versions file)
asdf global coursier latest

# Now coursier commands are available
coursier --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/jiahuili430/asdf-coursier/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Jiahui Li](https://github.com/jiahuili430/)
