proc setIcon {} {
  set tkversion [info patchlevel]
  set minor [lindex [split $tkversion .] 1]
  if { $minor > 4} {
    wm iconphoto . [image create photo -file icon.gif]
  }
}