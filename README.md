## bake - a pure bash project automation tool

> `bake`: The best thing since sliced artisanal organic heirloom sourdough cultured ... no, no, lets calm down, its just an automation tool.

Pure bash build framework.  No libraries, no dependencies (in this framework).  Designed in the spirit of rake and make.  I wished for a self-contained tool that did not require any more bootstrapping than running curl or a single `scp`, so I made this.

The API follows in the spirit of Ruby's amazing and wonderful Rake utility.

## Installation

### Via [`homebrew`](http://brew.sh/) or [`linuxbrew`](http://linuxbrew.sh/)

I (Kyle Burton) have a custom [brew tap](https://github.com/kyleburton/homebrew-kyleburton), to use it to install `bake` do the following on a system where you already have `brew` installed:

```sh
brew tap github/kyleburton https://github.com/kyleburton/homebrew-kyleburton.git

# recommended on OS X (bake depends on versions of bash that support arrays)
brew install github/kyleburton/bake

# recommended on Linux (Linux already has a good bash)
brew install github/kyleburton/bake --without-bash
```

### Manual

    test -d $HOME/bin || mkdir $HOME/bin
    curl https://raw.githubusercontent.com/kyleburton/bake/master/bake > $HOME/bin/bake
    chmod 755 $HOME/bin/bake

NOTE: OS X (the Apple Mac) has been regressing its version of bash.  Newer (as of 2016) versions of OS X have a bash that `bake` is incompatible with.  `bake` uses (arrays)[http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html], which very old versions of `bash` do not support.  You can easily install a modern supported version of bash via [homebrew](http://brew.sh/) and then either [set it as your shell](http://johndjameson.com/blog/updating-your-shell-with-homebrew/) or change the first line of the `bake` script to point to the bash you installed via homebrew.

# Getting Started

You can have `bake` create a skeleton `Bakefile` in your current working directory by running:

```sh
bake init
```

## Lets Make Your first `Bakefile`!

Organizing code into libraries is recommended, so we're going to start off with showing how to do just that.  We're going to create a place to organize local modules `./test/lib` and create the file `./test/lib/mylib.sh` with our first `bake` task!  This is the 'hello world' for `bake`.


```sh
# Create a test folder to hold the bake libraries
test -d test/lib || mkdir -p test/lib

# Create library with a bake task
cat > 'test/lib/mylib.sh' <<'EOF'
#!/usr/bin/env bash
bake_task mylib:foo "The foo command just echo's its arguments"
function mylib:foo () {
  echo "foo: args='$@'"
}
EOF

# Create Bakefile to include libraries
cat > 'Bakefile' <<'EOF'
#!/usr/bin/env bash
bake_push_libdir $(bake_bakefile_dir)/test/lib
bake_require mylib
EOF
```

Then run bake:

```sh
$ bake

bake task [arg ...]

  mylib:foo                      The foo command just echo's its arguments


$ bake mylib:foo this that
foo: args='this that'
```

## The "API", aka what shell functions can you call from your `Bakefile`?

`bake` is controlled by a `Bakefile` (similarly to make and rake).  This file is just a bash script.  You define functions for your tasks and register them with `bake`.  `bake` itself is essentially a set of shell functions and you can (and are encouraged) to use them from within your `Bakefile`s.  This is an overview of the most useful ones (feel free to look around inside `bake` and see what else is there).

### `bake_task task-name "task-description"`

This registers a task and its description so it can be executed and a short help string.

### `bake_default_task task-name`

This registers the default task to be run if no task is passed on the command line.

### `bake_push_libdir path`

Pushes a file system path onto the front of `BAKEPATH`.

### `bake_add_libdir path`

Pushes a file system path onto the end of `BAKEPATH`.

### `bake_require libname`

Searches `BAKEPATH` for the library and sources it, loading the file (executing its contents).  Libraries should (generally) only contain declarations, as any imperative code will be executed when the library is loaded.  Libraries may load other libraries.

You can also load libraries from Github or Enterprise Github instances.  See the [Remote Libraries](#remote_libraries) section for more details.

## Look Ma, no `Bakefile` aka lets use a `./bake` directory

`bake` can also be used without a `Bakefile`, if you make a directory called `bake` and place shell files within it, `bake` will treat everything in that directory as library and require it automatically.  See the section on libraries below.


# Libraries

Some of the goals I had for for `bake` are for it to encourage best practices for shell scripting and to encourage re-use by encouraging the creation of small re-useable parts including libraries.  Bake encourages small re-useable functions essentially by requiring the use of shell functions.  It's up to you to break your functions into libraries that can be shared across your projects.  Have a look at the [Best Practices](#best-practices) section below.

## Remote Libraries

Loading via Github via http/https
```
bake_require github.com/john/bakelib/my_bake_funcs
bake_require https://github.com/john/bakelib/my_bake_funcs
```

Or via ssh
```
bake_require ssh://github.acme.com/john/bakelib/my_bake_funcs
bake_require git@github.acme.com:john/bakelib.git/my_bake_funcs
```

You can also load from branches or tags
```
bake_require ssh://github.acme.com/john/bakelibs/my_bake_funcs develop
bake_require github.com/steve/examples/lib1 1.0.2
```

If you want to update your locally installed version of the libraries, you can run `bake update`

### `BAKEPATH`

This is a colon separated list of paths that `bake_require` uses to locate libraries.


# Best Practices

This section is chock full of tips for how to get the most out of your `bake` experience!

* Be Robust
* Be Helpful
* Extract configuration and parameters into environment variables, place these at the top of your script.
* Use defaults `${MYTHING_VERSION:-1.0.7}`
* `init()`
* Manage the Current Working Directory (`$PWD`) with care
* Don't re-define built-ins, be thoughtful with `exec`
* Fake it till you make it: prefixes as namespaces help avoid collisions, and aid in organization
* Return instead of exit, but use return values please!
* Don't put naked shell code in your `Bakefile` or libraries if you can help it!
* Idempotency is your friend, take the time to make your functions idempotent
* When Enough is Enough, Graduate to a More Powerful Tool

#### Be Helpful

Use exit codes to indicate success or failure.  If you write a function that detects an error and exits, use 'return 1' so the calling shell knows that your task did not succeed.  This is important for your CI server and any other automation around your `Bakefile`.

#### Be Helpful

Be kind to yourself and others, write brief but descriptive task descriptions.  Use your configuration variables in your task descriptions so users know what settings are.

```sh
#!/usr/bin/env bash

CONFIG="${CONFIG:-config/development.env}"

bake_task init "Initialize the environment from CONFIG=$CONFIG"
function init () {
  bake_echo_red "Implement me, I'm just an example"
  return 1
}
```

Write descriptive help using Bake's comment based help annotations:

```
# @help.init|init sets up your local environment, pulling defaults from $CONFIG
# @help.init|required development tooling will automatically be installed.
# @help.init|please ensure you have the required disk space and authorizations.
bake_task init "Initialize the environment from CONFIG=$CONFIG"
function init () {
  bake_echo_red "Implement me, I'm just an example"
  return 1
}
```

Its extra work, though defaulting your required task arguments to the empty string and testing if they are empty so you can provide a sensible error message (and return an error code) can be very helpful:

```sh
S3_BUCKET="cdyne-aicore"
bake_task fetch-s3-package "Fetch a local software package from our s3 bucket ($S3_BUCKET)"
function fetch-s3-package () {
  local s3path="${1:-}"

  if [ -z "$s3path" ]; then
    bake_echo_red "Error: you must supply a path and filename (s3path) to be fetched."
    return 1
  fi

  local fname="$(basename "$s3path")"

  aws s3 cp "s3://$S3_BUCKET/$s3path"  "$fname"
}
```

## Configuration at the top

Extract configuration and parameters into environment variables, place these at the top of your script.  This will help anyone looking at your `Bakefile` or libraries understand what configuration options you're using and how to set or override them.

```sh
# config/development.env
INSTALL_TARGET="/opt/cyberdyne.com/skynet"
SKYNET_VERSION="20730401.b99879213"
SKYNET_PERSONALITY_MODULE="Serena-Kogan.nnaipkg"
```

Alternatively using an external configuration file with environment variables can help mange more complex configuration needs:

```sh
#!/usr/bin/env bash

CONFIG="${CONFIG:-config/development.env}"

function init () {
  if [ ! -e "$CONFIG" ]; then
    bake_echo_red "Error: please copy $CONFIG.template to $CONFIG and
    bake_echo_red "fill in the required parameters."
    return 1
  fi
  source "$CONFIG"
}

bake_task install "Install the things into $INSTALL_TARGET"
function install () {
  init
  bake_echo_green "Installing into $INSTALL_TARGET"
  ...
}
```

```sh
# use the default configuration:
$ bake

# specify an alternative:
$ CONFIG=config/sfo-research-site.env bake

# or
$ export CONFIG=config/sfo-research-site.env
$ bake
```

## Use defaults for your configuration `${MYTHING_VERSION:-1.0.7}`

This is a nice way to support defaults and allow users to override them ad-hoc by setting the environment variables before invoking your bake tasks or loading your library.

## `init()`

Instead of putting initialization in your libraries or `Bakefile` outside of a function, placing it into an `init` function helps keep it organized and ensure it's consistently called from the tasks that need it.  Making it idempotent is another best practice, as you will no longer have to worry about side effects.

```sh
CONFIG="${CONFIG:-config/development.json}"
ALEMBIC_CONFIG="${ALEMBIC_CONFIG:-config/development.alembic.ini}"

function init () {
  if [ -n "${INIT_CALLED:-}" ]; then
    return 0
  fi

  # check configuration
  if [ ! -e "$CONFIG" ]; then
    bake_echo_red "Please copy config/config-template.json to $CONFIG"
    bake_echo_red "and fill in the required values (such as the database connection parameters)"
    return 1
  fi

  if [ ! -e "$ALEMBIC_CONFIG" ]; then
    bake_echo_red "Please copy config/alembic-config-template.ini to $ALEMBIC_CONFIG"
    bake_echo_red "and fill in the required values (such as the database connection parameters)"
    return 1
  fi

  # make sure our prerequisites are installed
  pip install -r requirements.txt

  INIT_CALLED="true"
  return 0
}


bake_task alembic "Wrapper for database migrations tooling"
function alembic () {
  init
  command alembic -c "$ALEMBIC_CONFIG" "$@"
}

bake_task dev:run-server "Run the server in development mode"
function dev:run-server () {
  python -m skynet.ai.servcie
}
```

## Be thoughtful with your `$PWD`

Use sub-shells, use `pushd` and `popd` (keep in mind that they're noisy).

## Avoid Re-definition of built-ins and standard commands

Besides the redefinition of `bake`s own functions, you should avoid redefinition of any of the `bash` built-ins such as `test` (I've done this, and now I use `run-test` instead of `test`).  If you find that you have a case for redefinition of a standard command, perhaps because you'd like to wrap it with some additional behavior, you can still call out to it with `bash`s `command`:

```sh
#!/usr/bin/env bash
ALEMBIC_CONFIG="${ALEMBIC_CONFIG:-config/development.alembic.ini}"

bake_task alembic "Wrapper for database migrations tooling"
function alembic () {
  command alembic -c "$ALEMBIC_CONFIG" "$@"
}
```

## Namespaces

`bash` technically doesn't have namespaces for functions, yet it allows for periods `.` and colons `:` in the names of shell functions.  Using these allows us to get many of the benefits of namespaces.

Here's an example of using colons `:` for namespacing


```
# in the file ./lib/mylib.sh

bake_task mylib:hello-word "This is the hello world task!"
function mylib:hello-word () {
  bake_echo_green "Hello World!"
}
```

## Don't use `exit`, use `return`

`exit` will, as it's supposed to, exit the entire process, terminating your `bake` process.  This is rarely, if ever, what you really want to do from any of your bash functions.  Each of your `bake` tasks should return an explicit error (not zero) or success (zero) value from every branch of the code.

## Don't put naked shell code in your `Bakefile` or libraries if you can help it!

This will end up executing every time the code is required or loaded.  This increases complexity and will make re-use of your code more challenging.


## Idempotency is your friend, take the time to make your functions idempotent

This is simplest through judicious use of `bash`s built-ins like `test` to look for expected output files before executing commands:

```sh
bake_task download-package "Download the package $MYPKG_URL"
function download-package () {
  local pkgfile="$(basename "$MYPKG_URL")"
  test -f "$pkgfile" || curl "$MYPKG_URL" > "$pkgfile"
}
```

## When Enough is Enough, Graduate to a More Powerful Tool

Although `bake` ultimately has all the same features and expressiveness as shell scripting in `bash`, and is quite capable, it's intended to be for lightweight project automation.  If you find yourself needing a lot of additional utilities to be installed to run your `Bakefile`s or have significant and complex logic, and ultimately need a more fully featured build tool or programming language you should graduate to one.  `bake` may still be there for you as what it was intended for - a helpful task runner for your more complex steps.

# My Thoughts on `bake` vs Other Build and Project Automation Tools

`make` is definitely more standard, has built in facilities for performing dependency analysis and is a much better suited tool for the parts of your project that are working with C and C++ source code.  Though `make` introduces additional complexity if you need to implement additional logic, you're free to embed shell commands, though the rules for escaping special characters between `make` and `bash` tends to get complex quickly.  Re-use in `make` can be trickier than in shell scripts.  `make` isn't a task runner, though you can use `.PHONY` targets to simulate this, it doesn't have a facility for offering a catalog of available tasks along with descriptions.

`rake` is a wonderful tool, providing a succinct, internal, DSL for defining tasks and scaling up to the full `ruby` programming language.  For my use-cases it brought with it the complexity of managing the installation and run-time of both ruby and various libraries.

# Further Reading

`bake` is at its core a collection of shell function and strongly followed conventions.  Learning `bash` is therefor a great idea for getting the most out of `bake`.  This has the added benefit of becoming great at that venerable, widely applicable skill: shell scripting.

* https://www.quora.com/What-are-some-good-books-for-learning-Linux-bash-or-shell-scripting
* http://guide.bash.academy/
* http://www.tldp.org/LDP/Bash-Beginners-Guide/html/

# Creating a Release

```
cd build
bake make-release
```

Gzip the `./release/bake-$VERSION` directory and add it to the github release.  Update the homebrew tap with the new download link for the `tgz` file and it's sha256 sum.

# Contributors

* Kyle Burton &lt;kyle.burton@gmail.com&gt;
* Isaac Schaaf &lt;zeekus99@gmail.com&gt;
* Steve Hajducko &lt;hajducko@gmail.com&gt;
* Asif Shaikh &lt;ripclaw_ffb@hotmail.com&gt;

# License

Copyright (C) 2014-2016 Kyle Burton &lt;kyle.burton@gmail.com&gt;

Distributed under the Eclipse Public License, the same as Clojure.
