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

# BODY FRAME
frame .body -background gray10 -height 480 -width 480
pack .body -side left -anchor w -expand true -fill both -after .sidebar

# DOCUMENT VARIABLES
set activeFile ""
set activeFileType ""
# Sidebar Y scroll position
set sbY 72

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
proc newIcon { itemId itemUrl } {
  set icon [image create photo  -file $itemUrl]
  return [label .$itemId -image $icon -background gray15 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w]
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
  global sbY
  set searchQuerry [.searchInputHandle get 0.0 "end - 1 char"]
  if {$searchQuerry eq ""} {
    set files [glob -nocomplain *]
  } else {
    set files [glob -nocomplain *{$searchQuerry}*]
  }
  set files [lsort -dictionary $files]
  set fileId 0
  update
  set sidebarH [winfo height .sidebar]
  set lsbY $sbY

  foreach file $files {
    destroy .$fileId  
    if {$lsbY >= 46 && $lsbY < $sidebarH } {
      set .fileId [newMenuItem $fileId $file]
      bind .$fileId <ButtonPress-1> [list openPath $file] 
      place .$fileId -in .sidebar -x 0 -y $lsbY -width 160 -height 26
    }
    incr lsbY 26
    incr fileId
  }
  # Button for directory navigation
  destroy .dirUpButton
  set .dirUpButton [newMenuItem .dirUpButton ".Parent Folder"]
  place .dirUpButton -in .sidebar -x 0 -y 46 -width 160 -height 26
  bind .dirUpButton <ButtonPress-1> openParent

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
    global sbY
    if { [expr $sbY + $D] <= 72 } {
      incr sbY $D
      fillSidebarFileMenu
    }
  }
}

proc applySearch {} {
  global sbY
  set sbY 72
  fillSidebarFileMenu
}

# SEARCH INPUT
newTextInput "searchInputHandle"
place .searchInputHandle -in .sidebar -x 10 -y 10 -width 140 -height 26
set .searchIcon [newIcon searchIcon search.gif]
place .searchIcon -in .sidebar -x 125 -y 11 -width 24 -height 24
#set .arrowUpIcon [newIcon arrowUpIcon arrow-up.gif]
#place .arrowUpIcon -in .sidebar -x 100 -y 11 -width 24 -height 24

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
bind .  <Button-4> {event generate [focus -displayof %W] <MouseWheel> -delta 1}
bind . <Button-5> {event generate [focus -displayof %W] <MouseWheel> -delta -1}


# FILE LIST
fillSidebarFileMenu


