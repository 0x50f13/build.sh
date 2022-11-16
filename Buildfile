
target_install(){
  info "Installing to /usr/bin/build"
  require_root
  require_command cp
  require_command chmod
  require_directory /usr/bin/
  info "Setting access permisson for all users"
  exec chmod 777 build.sh
  info "Copying script"
  exec cp build.sh /usr/bin/build
}
