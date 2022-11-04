# build.sh
build.sh provides a bash framework for building and meta-building complex software.
## Supported platforms
The `build.sh` is tested on Mac OS X 10.15.7 and various Linux distributions(Alpine, Ubuntu)
### Requirements
  * bash>4.1
  * Terminal with color support is recommended
## Quickstart
### Installation
  In order to install build.sh the following steps should be done:
  ```
  $ git clone https://github.com/Andrewerr/build.sh
  $ chmod 755 build.sh
  $ sudo ./build.sh install
  ```
### Embedded usage
  You can use `build.sh` without installation:<br>
  ```
  $ git clone https://github.com/Andrewerr/build.sh
  $ chmod 755 build.sh
  $ mv build.sh build
  $ export "PATH=$PATH:$(pwd)"
  $ # Now you can use `build` command in this session
  ```
### Buildfile
  The `build.sh` searches for file called `Buildfile` in your current directory.
  The `Buildfile` is basically a shell-script, but it will be loaded with `build.sh` and
  the functions in it beggining with `target_` would be available for calling from shell.
### Defining targets
  The key concept is target. The targets is a bash function which is processed by `build.sh`. In order to call target you can use `build <target-name>`.
  To add target to your build file write:
  ```
  target_target-name(){
    # Build steps are here
  }
  ```
### Hello, world!
  Here is a simple example of `Buildfile` which prints "Hello, world".
  ```bash
  target_hello(){
    info "Hello,world!"
  }
  ```
  To execute this file simply enter `build hello`
### Using variables
  ```bash
  USERNAME="$(whoami)"
  target_hello(){
    info "Hello, $USERNAME"
  }
  ```
  This file will print hello to name of current user.

### exec
  It is important to ensure that some commands are executed correctly. The built-in command `exec` will abort build if the command has failed.
  ```bash
  target_error(){
    exec "non_existent_command"
  }
  target_print(){   
    exec "printf '\n\nHello, world!\n\n'"
  }
  ```
  When you type `build error` you will see an error that execution of `non_existent_command` had failed. If you will type `build print` you will see `Hello,world` with information about what command was executed.

### requires
  In order to prevent build failing directly on exec you can apply `require_*` commands:
  * `require_root` -- check that current user is `root`
  * `require_command <command>` -- check that `<command>` is available in the system

### Files operations
  A files operationns can be done by pattern. 
  * `copy $pattern $target` -- copies files matching wilecard `$pattern` to `$target` directory.
  * `move $pattern $target` -- moves files matching wilecard `$pattern` to `$target` directory. 
# Todos
* [ ] Add `Dockerfile`
* [x] Implement `if def`, `if ndef`
* [ ] Incremental builds
`
