if exists("g:loaded_dots_plugin")
  finish
endif
let g:loaded_dots_plugin = 1

command! -nargs=0 DotsFmt call s:dots_fmt()

function! s:dots_fmt() abort
  if &modifiable == 0
    return
  endif
  let l:tmp = tempname()
  call writefile(getline(1, '$'), l:tmp)
  call system('dots fmt --write ' . shellescape(l:tmp))
  if v:shell_error == 0
    let l:new = readfile(l:tmp)
    call setline(1, l:new)
  endif
  call delete(l:tmp)
endfunction

function! DotsOmni(findstart, base) abort
  if a:findstart
    let l:line = getline('.')
    let l:col = col('.') - 1
    while l:col > 0 && l:line[l:col - 1] =~ '\k'
      let l:col -= 1
    endwhile
    return l:col
  endif
  let l:q = a:base
  let l:raw = system('dots search --json --kind fn ' . shellescape(l:q))
  return split(l:raw, '\n')
endfunction

augroup dots_plugin
  autocmd!
  autocmd FileType dots setlocal omnifunc=DotsOmni
augroup END

" Minimal textobjects for proc/form/entry blocks.
onoremap ap :<C-u>normal! ?^\s*\(proc\|form\|entry\)<CR>V/^\s*}<CR><CR>
xnoremap ap :<C-u>normal! ?^\s*\(proc\|form\|entry\)<CR>V/^\s*}<CR><CR>

