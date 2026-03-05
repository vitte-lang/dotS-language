if exists("b:current_syntax")
  finish
endif

syntax keyword dotsKeyword space pull form proc const let give loop if else continue break entry at
syntax match dotsComment /#.*/
syntax region dotsString start=/"/ skip=/\\"/ end=/"/
syntax match dotsNumber /\v<\d+>/
syntax match dotsCall /\v\.[A-Za-z0-9_\."]+\./

highlight default link dotsKeyword Keyword
highlight default link dotsComment Comment
highlight default link dotsString String
highlight default link dotsNumber Number
highlight default link dotsCall Function

setlocal commentstring=#\ %s

let b:current_syntax = "dots"

