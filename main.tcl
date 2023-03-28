#!/usr/bin/wish
# https://tcl.tk/man/tcl8.4/

wm title . "Textor"
wm geometry . 640x480+100+100

# SIDEBAR FRAME
frame .sidebar -background gray0 -height 480 -width 160
pack .sidebar -side left -anchor w -expand false -fill y

# BODY FRAME
frame .body -background gray5 -height 480 -width 480
pack .body -side left -anchor w -expand true -fill both -after .sidebar

# DOCUMENT VARIABLES
set activeFile ""

# NORMAL INPUT
proc newTextInput { inputId } {
    return [text .$inputId -font {Helvetica -12} -background gray10 -foreground gray50 -borderwidth 0 -highlightthickness 1 -highlightcolor gray25 -highlightbackground gray15 -selectborderwidth 0 -selectbackground turquoise -selectforeground turquoise4 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx 5 -pady 5]
}

# SIDEBAR MENU ITEM
proc newMenuItem { itemId itemText } {
    #return [button .$itemId -font {Helvetica -12} -text $itemText -command [list menuItemClicked $itemText] -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w]
    return [label .$itemId -font {Helvetica -12} -text $itemText -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w -padx 10]
}

# TEXT BOX
proc newTextBox { inputId } {
    return [text .$inputId -font {Courier -12} -background gray5 -foreground gray70 -borderwidth 0 -highlightthickness 0 -selectbackground DarkSlateGray -selectforeground gray80 -insertbackground gray50 -insertwidth 1 -insertofftime 500 -insertontime 500 -padx 15 -pady 15 -undo true -autoseparators true -wrap word ]
}

proc menuItemClicked { origin } {
    global activeFile
    set activeFile $origin
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

# ADDS BRACKET TAGS
proc addBracketTags {w} {
    set brackets [ list "\{" "\}" "\[" "\]" "\"" "\<" "\>"]
    foreach bracket $brackets {
        set cur 1.0
        while 1 {
            set cur [$w search $bracket $cur end]
            if {$cur eq ""} {break}
            $w tag add bracket $cur "$cur + 1 char"
            set cur [$w index "$cur + 1 char"]
        }
    }
    $w tag configure bracket -foreground gold
}

# ADDS VARIABLE TAGS
proc addVariableTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search "\$" $cur end]
        if {$cur eq ""} {break}
        $w tag add variable $cur "$cur + 1 char wordend"
        set cur [$w index "$cur wordend"]
    }
    $w tag configure variable -foreground DeepSkyBlue
}

# ADDS FLAG TAGS
proc addFlagTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search " -" $cur end]
        if {$cur eq ""} {break}
        # Don't highlight if used as minus
        set nextchar [$w get "$cur + 2 char"]
        if { $nextchar ne "\ " && $nextchar ne "\""} {
            $w tag add flag $cur "$cur + 2 char wordend"
        }
        set cur [$w index "$cur + 2 char wordend"]
    }
    $w tag configure flag -foreground MediumTurquoise
}

# ADDS KEYWORD TAGS
proc addKeywordTags {w} {
    set keywords [ list "proc " "set " "global " "foreach " "if " "while " "wm " "frame " "pack " "return " "event " "bind " ]
    foreach keyword $keywords {
        set cur 1.0
        while 1 {
            set cur [$w search $keyword $cur end]
            if {$cur eq ""} {break}
            $w tag add keyword $cur "$cur wordend"
            set cur [$w index "$cur wordend"]
        }
    }
    $w tag configure keyword -foreground MediumPurple1
}

# ADDS HANDLE TAGS
proc addHandleTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search " \." $cur end]
        if {$cur eq ""} {break}
        $w tag add handle $cur "$cur + 2 char wordend"
        $w tag remove variable $cur "$cur + 2 char wordend"
        set cur [$w index "$cur + 2 char wordend"]
    }
    $w tag configure handle -foreground CornflowerBlue
}

# ADDS COMMENT TAGS
proc addCommentTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search "\#" $cur end]
        if {$cur eq ""} {break}
        # Don't highlight if escaped
        if {[$w get "$cur - 1 char"] ne "\\"} {
            $w tag add comment $cur "$cur lineend"
            $w tag remove bracket $cur "$cur lineend"
        }
        set cur [$w index "$cur lineend"]
    }
    $w tag configure comment -foreground MediumSeaGreen
}

proc highlight {} {
    addBracketTags .textBoxHandle
    addVariableTags .textBoxHandle
    addFlagTags .textBoxHandle
    addKeywordTags .textBoxHandle
    addHandleTags .textBoxHandle
    addCommentTags .textBoxHandle
}

# Sidebar Y position iterator to place widgets at
set sbY 10

# SEARCH INPUT
newTextInput "searchInputHandle"
place .searchInputHandle -in .sidebar -x 10 -y $sbY -width 140 -height 26
incr sbY 36

# TEXT BOX
newTextBox "textBoxHandle"
place .textBoxHandle -in .body -relwidth 1.0 -relheight 1.0

# EVENT LISTENERS
event add <<Save>> <Control-s>
bind . <<Save>> {saveFile}

# FILE LIST
set files [glob *]
set fileId 0
foreach file $files {
    set .fileId [newMenuItem $fileId $file]
    bind .$fileId <ButtonPress-1> [list menuItemClicked $file] 
    place .$fileId -in .sidebar -x 0 -y $sbY -width 160 -height 26
    #set .fileId [label .$fileId -font {Helvetica -12} -text $file -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w]
    #bind .$fileId <ButtonPress-1> [list menuItemClicked $file] 
    #place .$fileId -in .sidebar -x 10 -y $sbY -width 140 -height 26
    incr sbY 26
    incr fileId
}

#puts [format "%s: %s" Clicked $origin]
#button .$fileId -text $file -command [list puts $fileId]
#cd ~
#button .$fileHandle -text $file -command buttonClicked -background gray0 -foreground gray50 -borderwidth 0 -highlightthickness 0 -activebackground gray2 -activeforeground gray60 -anchor w -font {Helvetica -12}

# AVAILABLE FONTS
# puts [font families]

#place $searchInputHandle -x 10 -y 10 -width 140 -height 30
#puts $searchInputHandle
#set textInputHandle [text .myText -font {Helvetica -16} -background gray20 -foreground gray80 -borderwidth 0 -highlightthickness 0 -padx 15 -pady 15]
# pack .myEntry -side left -anchor n -expand false
# grid $emtru

# grid -column, -columnspan, -in, -ipadx, -ipady, -padx, -pady, -row, -rowspan, or -sticky
# grid .body -column 160 -row 0 -columnspan 480
# grid .sidebar -column 0 -row 0 -columnspan 160

# grid [label .myLabel -text "Label Widget" -textvariable labelText]
# grid [text .myText -width 20 -height 5]
# .myText insert 1.0 "Text\nWidget\n"
# grid [entry .myEntry -text "Entry Widget" -textvariable labelText -font {Georgia -16}]

# grid [message .myMessage -background gray -foreground white -textvariable labelText]
# grid [button .myButton1  -text "Button" -command "set labelText clicked"]




































