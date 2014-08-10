## bake - bash [mr]ake

Pure bash build framework.  No libraries, no dependencies (in this framework).  Designed in the spirit of rake and make.  I wished for a self-contained tool that did not require any more boostrapping than running curl or a single scp, so I made this.

The API follows in the spirit of Ruby's amazing and wonderful Rake utility.

## Installation

    $ test -d $HOME/bin || mkdir $HOME/bin
    $ curl https://raw.githubusercontent.com/kyleburton/bake/master/bake > $HOME/bin/bake
    $ chmod 755 $HOME/bin/bake

## Example Bakefile

    $ mkdir test/lib
    $ cat >> test/lib/mylib.sh
    #!/usr/bin/env bash
    set -eu
    bake_task foo "The foo command just echos it's arguments"
    function foo () {
      echo "foo: args='$@'"
    }
    ^D

    $ cat >> Bakefile
    #!/usr/bin/env bash
    bake_push_libdir $(bake_bakefile_dir)/test/lib
    bake_require mylib
    ^D

Then run bake:

    $ bake
    
    bake task [arg ...]
    
      foo                            The foo command just echos it's arguments
    
    
    $ bake foo this that
    foo: args='this that'



## `Bakefile`

`bake` is controlled by a Bakefile (similarly to make and rake).  This file is just a bash script.  You define functions for your tasks and register them with `bake`.

### `bake_task task-name "task-description"`

This registers a task and it's description so it can be executed and help can be displayed.

### `bake_default_task task-name`

This registers the default task to be run if no task is passed on the command line.

## `bake_push_libdir path`

Pushes a file system path onto the front of `BAKEPATH`.

## `bake_add_libdir path`

Pushes a file system path onto the end of `BAKEPATH`.

## `bake_require libname`

Searches `BAKEPATH` for the library and sources it, loading the file (executing its contents).  Libraries should (generally) only contain declarations, as any imperative code will be executed when the library is loaded.  Libraries may load other libraries.

## Environment

### BAKEPATH

This is a colon separated list of paths that `bake_require` uses to locate libraries.

## License

Copyright (C) 2014 Kyle Burton &lt;kyle.burton@gmail.com&gt;

Distributed under the Eclipse Public License, the same as Clojure.

## TODO

* `bake_require_all path` : recursively load all the files under `path`
* implement dependency tracking, something like: `bake_deps a b c` where `bake_deps` just runs the deps and tracks if they've been run already.
* how can we support namespaces for tasks?
* support command line auto-completion for bake
