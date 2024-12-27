# Installation

## Dependencies

```bash
gem install rugged -- --use-system-libraries
gem install github-linguist -- --use-system-libraries
```

If not installed already, you may need to install the following C libraries:

```bash
pacman -S icu
pacman -S icu-devel
pacman -S libgit2
```

If you are using MSYS2, visit [this website](https://packages.msys2.org/search?q=icu) to figure out how to install the package for your system. If you get makefile errors, you may need to ensure that the `gem install` command can find the dependency `lib` files. Use `find` command to find out where these files are. For example:

```bash
find /usr -name 'libicu*' # Ex: to find -libicui18n.ddl.a
```

Then run the install command again by

```bash
gem install github-linguist -- --with-icu-lib={libdir}
```