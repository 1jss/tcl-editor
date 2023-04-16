#!/usr/bin/wish

source highlight-tcl.tcl
source highlight-md.tcl
# source [file join [file dirname [info script]] highlight-tcl.tcl]
# source [file join [file dirname [info script]] highlight-md.tcl]

wm title . "Tedit"
wm geometry . 640x480+100+100
wm iconphoto . [image create photo -file icon.gif]

# SIDEBAR FRAME
frame .sidebar -background gray0 -height 480 -width 160
pack .sidebar -side left -anchor w -expand false -fill y

# FILE MENU FRAME
canvas .sidecanvas -background green -height 408 -width 160 -confine true
place .sidecanvas -in .sidebar -x 0 -y 72 -relwidth 1.0 -relheight 1.0
frame .filemenu -background red -height 480 -width 160
.sidecanvas create line 0 0 160 408
.sidecanvas create window 0 0 -anchor nw -window .filemenu
.sidecanvas configure -scrollregion [list 0 0 160 160]
#.sidecanvas configure -scrollregion [list 0 0 160 [.sidebar cget -height]]

# BODY FRAME
frame .body -background gray10 -height 480 -width 480
pack .body -side left -anchor w -expand true -fill both -after .sidebar

# DOCUMENT VARIABLES
set activeFile ""
set activeFileType ""

# ICON IMAGES
set arrowUpImage [image create photo -file arrow-up.gif]
set searchImage [image create photo -file search.gif]

# SELECT AND APPLY HIGHLIGHT
proc highlight {} {
  global activeFileType
  if {$activeFileType==".tcl"} {
    highlightTcl .textBoxHandle
  } elseif {$activeFileType==".md"} {
    highlightMd .textBoxHandle
  }
}

# NORMAL INPUT
proc newTextInput { inputId } {
  return [text .$inputId -font {Helvetica -12} -background gray15 -foreground gray50 -borderwidth 0 -highlightthickness 1 -highlightcolor gray30 -highlightbackground gray20 -selectborderwidth 0 -selectbackground turquoise -selectforeground turquoise4 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx 5 -pady 5]
}

proc limitText { itemText goalWidth } {
  set textWidth [font measure {Helvetica -12} $itemText]
  if { $textWidth <= $goalWidth } { return $itemText }
  while { $textWidth > $goalWidth } {
    set itemText [string range $itemText 0 end-1]
    set textWidth [font measure {Helvetica -12} $itemText...]  
  }
  return $itemText...
}

# SIDEBAR MENU ITEM
proc newMenuItem { itemId itemText } {
  set shortText [limitText $itemText 140]
  return [label .$itemId -font {Helvetica -12} -text $shortText -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w -padx 10]
}

# ICON ON LABEL
proc newIconLabel { itemId image background } {
  return [label .$itemId -image $image -background $background -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w]
}

# TEXT BOX
proc newTextBox { inputId } {
  return [text .$inputId -font {Courier -12} -background gray10 -foreground gray70 -borderwidth 0 -highlightthickness 0 -selectbackground DarkSlateGray -selectforeground gray80 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx 15 -pady 15 -undo true -autoseparators true -wrap word ]
}

proc openFile { origin } {
  global activeFile
  global activeFileType
  set activeFile $origin
  set activeFileType [file extension $activeFile]
  set fileReader [open $activeFile r]
  .textBoxHandle delete 0.0 end
  .textBoxHandle insert 0.0 [read $fileReader]
  close $fileReader
  highlight
  wm title . $activeFile
}

proc saveFile {} {
  global activeFile
  if {$activeFile == ""} {
    return
  } else {
    set fileWriter [ open $activeFile w ]
    puts -nonewline $fileWriter [.textBoxHandle get 0.0 "end - 1 char"]
    close $fileWriter
  }
  highlight
}

proc openPath { path }  {
  if { [file isdirectory $path] } {
    cd $path
    fillSidebarFileMenu
  } elseif { [file isfile $path] } {
    cd [file dirname $path]
    openFile [file tail $path]
  }
}

proc openParent {} {
  set splitPath [lrange [file split [pwd]] 0 end-1 ]
  # If parent exists
  if {[llength $splitPath] > 0} {
    set newPath [eval [concat {file join} $splitPath]]
    if {[file isdirectory $newPath]} {
      cd $newPath
      fillSidebarFileMenu
    }
  }
}

# FILLS SIDEBAR FILE MENU
proc fillSidebarFileMenu {} {
  set searchQuerry [.searchInputHandle get 0.0 "end - 1 char"]
  if {$searchQuerry eq ""} {
    set files [glob -nocomplain *]
  } else {
    set files [glob -nocomplain *{$searchQuerry}*]
  }
  set files [lsort -dictionary $files]
  set fileId 0
  update
  set sidebarH [winfo height .filemenu]
  set lsbY 0
  foreach file $files {
    destroy .$fileId  
    if {$lsbY >= -26 && $lsbY < $sidebarH } {
      set .fileId [newMenuItem $fileId $file]
      bind .$fileId <ButtonPress-1> [list openPath $file] 
      place .$fileId -in .filemenu -x 0 -y $lsbY -width 160 -height 26
    }
    incr lsbY 26
    incr fileId
  }

  # Empty the rest of the list
  while {$fileId < 1000} {
    destroy .$fileId
    incr fileId
  }
}

proc indentRow {} {
  .textBoxHandle insert "insert linestart" "  "
}

proc scrollSidebar {x D} {
  if {$x <= 160} {
    .sidecanvas yview scroll $D units
  }
}

proc applySearch {} {
  fillSidebarFileMenu
}

# SEARCH INPUT
newTextInput "searchInputHandle"
place .searchInputHandle -in .sidebar -x 10 -y 10 -width 140 -height 26
set .searchIcon [newIconLabel .searchIcon $searchImage gray15]
place .searchIcon -in .sidebar -x 125 -y 11 -width 24 -height 24

# DIRECTORY NAVIGATION
set .arrowUpIcon [newIconLabel .arrowUpIcon $arrowUpImage gray0]
place .arrowUpIcon -in .sidebar -x 10 -y 46 -width 140 -height 24
bind .arrowUpIcon <ButtonPress-1> openParent

# TEXT BOX
newTextBox "textBoxHandle"
place .textBoxHandle -in .body -relwidth 1.0 -relheight 1.0

# OPEN FILE OR DIR FROM CMD ARGUMENT
set argument [lindex $argv 0]
openPath $argument
#proc ::tk::mac::OpenDocument {args} {
#  foreach f $args {openPath $f}
#  fillSidebarFileMenu
#}

# EVENT LISTENERS
event add <<Save>> <Control-s>
event add <<Save>> <Command-s>
bind . <<Save>> "saveFile"
event add <<Refresh>> <Control-r>
event add <<Refresh>> <Command-r>
bind . <<Refresh>> "fillSidebarFileMenu"
event add <<Indent>> <Tab>
bind .textBoxHandle <<Indent>> "indentRow; break"
event add <<Search>> <Return>
bind .searchInputHandle <<Search>> "applySearch; break"
event add <<Scroll>> <MouseWheel>
bind . <<Scroll>> {scrollSidebar %x %D}
bind . <Button-4> {
  set window %W
  if {$window ne ".textBoxHandle"} {scrollSidebar %x -1}
}
bind . <Button-5> {
  set window %W
  if {$window ne ".textBoxHandle"} {scrollSidebar %x 1}
}

# FILE LIST
fillSidebarFileMenu


