#!/bin/sh
# Start wish (#!/usr/bin/wish)  \
exec wish "$0" ${1+"$@"}

# REQUIRE TCK AND TK
package require Tcl
package require Tk

# source highlight-tcl.tcl
# source highlight-md.tcl
source [file join [file dirname [info script]] highlight-tcl.tcl]
source [file join [file dirname [info script]] highlight-md.tcl]

set scale 1
# if {[info exists env(TK_SCALING)]} { tk scaling $env(TK_SCALING) }

proc dpi { pixles } {
  global scale
  return [expr {$pixles*$scale}]
}

wm title . "Tedit"
wm geometry . [dpi 640]x[dpi 480]+100+100
wm iconphoto . [image create photo -file icon.gif]

tk scaling [expr {1.0/$scale}]

# SIDEBAR FRAME
frame .sidebar -background gray0 -height [dpi 480] -width [dpi 160]
pack .sidebar -side left -anchor w -expand false -fill y

# FILE MENU FRAME
canvas .sidecanvas -background gray0 -height [dpi 408] -width [dpi 160] -confine true -borderwidth 0 -highlightthickness 0
place .sidecanvas -in .sidebar -x 0 -y [dpi 72] -relwidth 1.0 -relheight 1.0

# BODY FRAME
frame .body -background gray10 -height [dpi 480] -width [dpi 480]
pack .body -side left -anchor w -expand true -fill both -after .sidebar

# DOCUMENT VARIABLES
set currentDir [pwd]
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
  return [text .$inputId -font {Helvetica -12} -background gray15 -foreground gray50 -borderwidth 0 -highlightthickness 1 -highlightcolor gray30 -highlightbackground gray20 -selectborderwidth 0 -selectbackground turquoise -selectforeground turquoise4 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx [dpi 5] -pady [dpi 5]]
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
  set shortText [limitText $itemText [dpi 140]]
  return [label .$itemId -font {Helvetica -12} -text $shortText -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w -padx [dpi 10]]
}

# ICON ON LABEL
proc newIconLabel { itemId image background } {
  return [label .$itemId -image $image -background $background -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w]
}

# TEXT BOX
proc newTextBox { inputId } {
  return [text .$inputId -font {Courier -12} -background gray10 -foreground gray70 -borderwidth 0 -highlightthickness 0 -selectbackground DarkSlateGray -selectforeground gray80 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx [dpi 15] -pady [dpi 15] -undo true -autoseparators true -wrap word ]
}

proc openFile { origin } {
  global currentDir
  global activeFile
  global activeFileType
  set activeFile $origin
  set activeFileType [file extension $activeFile]
  set fullPath [file join $currentDir $activeFile]
  set fileReader [open $fullPath r]
  .textBoxHandle delete 0.0 end
  .textBoxHandle insert 0.0 [read $fileReader]
  close $fileReader
  highlight
  wm title . $activeFile
}

proc saveFile {} {
  global currentDir
  global activeFile
  set fullPath [file join $currentDir $activeFile]
  if {$activeFile == ""} {
    return
  } else {
    set fileWriter [ open $fullPath w ]
    puts -nonewline $fileWriter [.textBoxHandle get 0.0 "end - 1 char"]
    close $fileWriter
  }
  highlight
}

proc openPath { path }  {
  global currentDir
  set fullPath [file join $currentDir $path]
  if { [file isdirectory $fullPath] } {
    set currentDir $fullPath
    fillSidebarFileMenu
  } elseif { [file isfile $fullPath] } {
    set currentDir [file dirname $fullPath]
    openFile [file tail $fullPath]
  }
}

proc openParent {} {
  global currentDir
  set splitPath [lrange [file split $currentDir] 0 end-1 ]
  # If parent exists
  if {[llength $splitPath] > 0} {
    set newPath [eval [concat {file join} $splitPath]]
    if {[file isdirectory $newPath]} {
      set currentDir $newPath
      fillSidebarFileMenu
    }
  }
}

# FILLS SIDEBAR FILE MENU
proc fillSidebarFileMenu {} {
  global currentDir
  set searchQuerry [.searchInputHandle get 0.0 "end - 1 char"]
  if {$searchQuerry eq ""} {
    set files [glob -directory $currentDir -tails -nocomplain *]
  } else {
    set files [glob -directory $currentDir -tails -nocomplain *{$searchQuerry}*]
  }
  set files [lsort -dictionary $files]
  set fileId 0
  set lsbY 0
  foreach file $files {
    destroy .$fileId
    set .fileId [newMenuItem $fileId $file]
    bind .$fileId <ButtonPress-1> [list openPath $file]
    .sidecanvas create window 0 $lsbY -anchor nw -window .$fileId
    incr lsbY [dpi 26]
    incr fileId
  }
  .sidecanvas configure -scrollregion [list 0 0 160 [expr {$lsbY+72}]]
  .sidecanvas yview moveto 0

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
  if {$x <= [dpi 160]} {
    .sidecanvas yview scroll [expr -$D] units
  }
}

proc applySearch {} {
  fillSidebarFileMenu
}

# OPEN NEW WINDOW
proc newWindow {} {
  interp create child
  child eval {source [file join [file dirname [info script]] main.tcl]}
}

# TEXT BOX
newTextBox "textBoxHandle"
place .textBoxHandle -in .body -relwidth 1.0 -relheight 1.0

# OPEN FILE OR DIR FROM CMD ARGUMENT
catch {
  set argument [lindex $argv 0]
  openPath $argument
}
#proc ::tk::mac::OpenDocument {args} {
#  foreach f $args {openPath $f}
#  fillSidebarFileMenu
#}

# SEARCH INPUT
newTextInput "searchInputHandle"
place .searchInputHandle -in .sidebar -x [dpi 10] -y [dpi 10] -width [dpi 140] -height [dpi 26]

# FILE LIST
fillSidebarFileMenu

set .searchIcon [newIconLabel .searchIcon $searchImage gray15]
place .searchIcon -in .sidebar -x [dpi 125] -y [dpi 11] -width [dpi 24] -height [dpi 24]

# DIRECTORY NAVIGATION
set .arrowUpIcon [newIconLabel .arrowUpIcon $arrowUpImage gray0]
place .arrowUpIcon -in .sidebar -x [dpi 10] -y [dpi 46] -width [dpi 140] -height [dpi 24]
bind .arrowUpIcon <ButtonPress-1> openParent

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
  if {$window ne ".textBoxHandle"} {scrollSidebar %x 1}
}
bind . <Button-5> {
  set window %W
  if {$window ne ".textBoxHandle"} {scrollSidebar %x -1}
}
event add <<NewWindow>> <Control-n>
event add <<NewWindow>> <Command-n>
bind . <<NewWindow>> "newWindow"

# REMOVE SELECTION ON PASTE
bind .textBoxHandle <<Paste>> {
  catch {
    catch { %W delete sel.first sel.last }
    %W insert insert [selection get -displayof %W -selection CLIPBOARD]
    tkEntrySeeInsert %W
  }
  break
}