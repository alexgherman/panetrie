# Documentation

### Project structure

Here is the breakdown of files:

```
├── etc
│   └── panetrie
│       └─── panetrie.conf
├── usr
│   ├── share
│   │   ├── libalpm
│   │   │   ├── hooks
│   │   │   │   └─── panetrie.hook
│   │   │   └── scripts
│   │   │       └─── panetrie
│   │   └── panetrie
│   │       └── panetrie.conf.example
│   └── bin
│       └─── panetrie -> /usr/share/libalmp/hooks.bin/panetrie
```

#### /etc/panetrie/panetrie.conf

Configuration file used to customize panetrie. Use this file to configure panetrie based on your specific workflow. An example is provided in `/usr/share/panetrie/panetrie.conf.example`.

To customize, either manually copy this file to `/etc/panetrie/panetrie.conf` or run `$ panetrie init-config` and go through the steps.

#### /usr/share/panetrie/panetrie.conf.example

Example configuration file containing all available customization options.

#### /usr/share/libalpm/hooks/panetrie.hook

A simple pacman alpm hook that plugs into pacman. Anytime a package is installed, removed or upgraded the hook is called.

For more information on alpm hooks, see [alpm-hooks(5)](https://man.archlinux.org/man/alpm-hooks.5).

#### /usr/share/libalpm/scripts/panetrie

Panetrie shell script executable.

#### /usr/bin/panetrie

Handy symlink pointing to `/usr/share/libalpm/hooks.bin/panetrie` to expose panetrie without specifying the full path.

### :book: Usage

:construction: Nothing here yet :construction:

### FAQ

:construction: Nothing here yet :construction:
