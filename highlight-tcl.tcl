# ADDS BRACKET TAGS
proc addTclBracketTags {w} {
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
proc addTclVariableTags {w} {
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
proc addTclFlagTags {w} {
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
proc addTclKeywordTags {w} {
  set keywords [ list "proc " "set " "global " "foreach " "if " "elseif " "else " "while " "wm " "frame " "pack " "return " "event " "bind " "destroy " ]
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
proc addTclHandleTags {w} {
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
proc addTclCommentTags {w} {
  set cur 1.0
  while 1 {
    set cur [$w search "\#" $cur end]
    if {$cur eq ""} {break}
    # Don't comment out if escaped
    if {[$w get "$cur - 1 char"] ne "\\"} {
      $w tag add comment $cur "$cur lineend"
      $w tag remove bracket $cur "$cur lineend"
    }
    set cur [$w index "$cur lineend"]
  }
  $w tag configure comment -foreground MediumSeaGreen
}

proc highlightTcl {handle} {
  $handle tag remove bracket 0.0 end
  addTclBracketTags $handle
  addTclVariableTags $handle
  addTclFlagTags $handle
  addTclKeywordTags $handle
  addTclHandleTags $handle
  addTclCommentTags $handle
}



