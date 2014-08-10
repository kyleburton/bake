# bake - bash [mr]ake

Pure bash build framework.  No libraries, no dependencies (in this framework).  Designed in the spirit of rake and make.  I wished for a self-contained tool that did not require any more boostrapping than running curl or a single scp.

The API follows in the spirit of Ruby's amazing Rake utility.

# Installation

    test -d $HOME/bin || mkdir $HOME/bin
    curl https://raw.githubusercontent.com/kyleburton/sandbox/bake/bake > $HOME/bin/bake
    chmod 755 $HOME/bin/bake

# Example Bakefile

    mkdir test/lib
    cat >> test/lib/mylib.sh
    #!/usr/bin/env bash
    set -eu
    bake_task foo "The foo command just echos it's arguments"
    function foo () {
      echo "foo: args='$@'"
    }
    ^D

    cat >> Bakefile
    #!/usr/bin/env bash
    bake_push_libdir $(bake_bakefile_dir)/test/lib
    bake_require mylib
    ^D

Then run bake:

    bake
    bake foo

