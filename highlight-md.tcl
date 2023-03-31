# ADDS BOLD TAGS
proc addMdBoldTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search -count length -regexp {(\*){2}(\S+)(\*){2}} $cur end]
        if {$cur eq ""} {break}
        $w tag add bold $cur "$cur + $length char"
        $w tag remove variable $cur "$cur + $length char"
        set cur [$w index "$cur + $length char"]
    }
    $w tag configure bold -font {Courier -12 bold}
}

# ADDS ITALIC TAGS
proc addMdItalicTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search -count length -regexp {(\*){1}(\S+)(\*){1}} $cur end]
        if {$cur eq ""} {break}
        $w tag add italic $cur "$cur + $length char"
        $w tag remove variable $cur "$cur + $length char"
        set cur [$w index "$cur + $length char"]
    }
    $w tag configure italic -font {Courier -12 italic}
}

# ADDS HEADING TAGS
proc addMdHeadingTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search "\#" $cur end]
        if {$cur eq ""} {break}
        # Don't comment out if escaped
        if {[$w get "$cur - 1 char"] ne "\\"} {
            $w tag add heading $cur "$cur lineend"
            $w tag remove bracket $cur "$cur lineend"
        }
        set cur [$w index "$cur lineend"]
    }
    $w tag configure heading -font {Courier -24 bold} -foreground MediumSeaGreen
}

proc highlightMd {handle} {
    $handle tag remove bracket 0.0 end
    addMdHeadingTags $handle
    addMdItalicTags $handle
    addMdBoldTags $handle
}



