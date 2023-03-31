#!/usr/bin/wish
# https://tcl.tk/man/tcl8.4/
source highlight-tcl.tcl
source highlight-md.tcl

wm title . "Textor"
wm geometry . 640x480+100+100

# SIDEBAR FRAME
frame .sidebar -background gray0 -height 480 -width 160
pack .sidebar -side left -anchor w -expand false -fill y

# BODY FRAME
frame .body -background gray10 -height 480 -width 480
pack .body -side left -anchor w -expand true -fill both -after .sidebar

# DOCUMENT VARIABLES
set activeFile ""
set activeFileType ""

# SELECT HIGHLIGHT
proc highlight {} {
    global activeFileType
    if {$activeFileType=="tcl"} {
        highlightTcl .textBoxHandle
    } elseif {$activeFileType=="md"} {
        highlightMd .textBoxHandle
    }
}

# NORMAL INPUT
proc newTextInput { inputId } {
    return [text .$inputId -font {Helvetica -12} -background gray15 -foreground gray50 -borderwidth 0 -highlightthickness 1 -highlightcolor gray30 -highlightbackground gray20 -selectborderwidth 0 -selectbackground turquoise -selectforeground turquoise4 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx 5 -pady 5]
}

# SIDEBAR MENU ITEM
proc newMenuItem { itemId itemText } {
    return [label .$itemId -font {Helvetica -12} -text $itemText -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w -padx 10]
}

# TEXT BOX
proc newTextBox { inputId } {
    return [text .$inputId -font {Courier -12} -background gray10 -foreground gray70 -borderwidth 0 -highlightthickness 0 -selectbackground DarkSlateGray -selectforeground gray80 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx 15 -pady 15 -undo true -autoseparators true -wrap word ]
}

proc menuItemClicked { origin } {
    global activeFile
    global activeFileType
    set activeFile $origin
    set activeFileType [lrange [split $activeFile .] end end]

    set fileReader [open $activeFile r]
    .textBoxHandle delete 0.0 end
    .textBoxHandle insert 0.0 [read $fileReader]
    close $fileReader
    
    highlight
}

proc saveFile {} {
    global activeFile
    if {$activeFile == ""} {
        return
    } else {
        set fileWriter [ open $activeFile w ]
        puts -nonewline $fileWriter [.textBoxHandle get 0.0 end]
        close $fileWriter
    }
    highlight
}

# FILLS SIDEBAR FILE MENU
proc fillSidebarFileMenu {} {
    # Sidebar Y position iterator to place widgets at
    set sbY 46
    set files [glob *]
    set fileId 0

    foreach file $files { 
        destroy .$fileId
        set .fileId [newMenuItem $fileId $file]
        bind .$fileId <ButtonPress-1> [list menuItemClicked $file] 
        place .$fileId -in .sidebar -x 0 -y $sbY -width 160 -height 26
        incr sbY 26
        incr fileId
    }
}

# SEARCH INPUT
newTextInput "searchInputHandle"
place .searchInputHandle -in .sidebar -x 10 -y 10 -width 140 -height 26

# TEXT BOX
newTextBox "textBoxHandle"
place .textBoxHandle -in .body -relwidth 1.0 -relheight 1.0

# EVENT LISTENERS
event add <<Save>> <Control-s>
event add <<Save>> <Command-s>
bind . <<Save>> {saveFile}
event add <<Refresh>> <Control-r>
event add <<Refresh>> <Command-r>
bind . <<Refresh>> {fillSidebarFileMenu}

# FILE LIST
fillSidebarFileMenu



















