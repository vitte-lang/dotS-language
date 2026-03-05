if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetDotsIndent()
setlocal indentkeys=o,O,0},0],0),:,0#

function! GetDotsIndent() abort
  let lnum = prevnonblank(v:lnum - 1)
  if lnum <= 0
    return 0
  endif

  let line = getline(lnum)
  let ind = indent(lnum)

  if line =~ '{\s*$'
    let ind += &shiftwidth
  endif
  if getline(v:lnum) =~ '^\s*}'
    let ind -= &shiftwidth
  endif
  if ind < 0
    let ind = 0
  endif
  return ind
endfunction

