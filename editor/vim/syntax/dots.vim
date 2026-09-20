if exists("b:current_syntax")
  finish
endif

syntax keyword dotsStorageKeyword space pull form proc give begin end
syntax keyword dotsModuleKeyword module use import
syntax keyword dotsStatementKeyword fn set let const call ret
syntax keyword dotsControlKeyword if elif else loop while for break continue try catch throw
syntax keyword dotsOperatorKeyword as and or not in case
syntax keyword dotsLiteralKeyword true false null
syntax keyword dotsTypeKeyword int i32 i64 f64 bool string bytes ptr result void any
syntax match dotsComment /#.*/
syntax region dotsString start=/"/ skip=/\\"/ end=/"/
syntax match dotsNumber /\v<\d+>/
syntax match dotsVariable /\v\$[A-Za-z_][A-Za-z0-9_]*/
syntax match dotsQualified /\v^\s*[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$/

highlight default link dotsStorageKeyword PreProc
highlight default link dotsModuleKeyword Include
highlight default link dotsStatementKeyword Statement
highlight default link dotsControlKeyword Conditional
highlight default link dotsOperatorKeyword Operator
highlight default link dotsLiteralKeyword Constant
highlight default link dotsTypeKeyword Type
highlight default link dotsComment Comment
highlight default link dotsString String
highlight default link dotsNumber Number
highlight default link dotsVariable Identifier
highlight default link dotsQualified Function

setlocal commentstring=#\ %s

let b:current_syntax = "dots"
