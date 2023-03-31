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

# ADDS H1 HEADING TAGS
proc addMdH1HeadingTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search -count length -regexp {^\#\ } $cur end]
        if {$cur eq ""} {break}
        # Don't comment out if escaped
        if {[$w get "$cur - 1 char"] ne "\\"} {
            $w tag add heading1 $cur "$cur lineend"
            $w tag remove bracket $cur "$cur lineend"
        }
        set cur [$w index "$cur lineend"]
    }
    $w tag configure heading1 -font {Courier -24 bold}
}

# ADDS H2 HEADING TAGS
proc addMdH2HeadingTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search -count length -regexp {^\#\#\ } $cur end]
        if {$cur eq ""} {break}
        # Don't comment out if escaped
        if {[$w get "$cur - 1 char"] ne "\\"} {
            $w tag add heading2 $cur "$cur lineend"
            $w tag remove bracket $cur "$cur lineend"
        }
        set cur [$w index "$cur lineend"]
    }
    $w tag configure heading2 -font {Courier -20 bold}
}
# ADDS H3 HEADING TAGS
proc addMdH3HeadingTags {w} {
    set cur 1.0
    while 1 {
        set cur [$w search -count length -regexp {^\#\#\#\ } $cur end]
        if {$cur eq ""} {break}
        # Don't comment out if escaped
        if {[$w get "$cur - 1 char"] ne "\\"} {
            $w tag add heading3 $cur "$cur lineend"
            $w tag remove bracket $cur "$cur lineend"
        }
        set cur [$w index "$cur lineend"]
    }
    $w tag configure heading3 -font {Courier -16 bold}
}
proc highlightMd {handle} {
    $handle tag remove heading1 0.0 end
    $handle tag remove heading2 0.0 end
    $handle tag remove heading3 0.0 end
    addMdH1HeadingTags $handle
    addMdH2HeadingTags $handle
    addMdH3HeadingTags $handle
    addMdItalicTags $handle
    addMdBoldTags $handle
}




