" vim plugin to go to header super quickly
" Assouline Yohann
" October 2019

if exists('g:goto_header_loadded')
    finish
endif
let g:goto_header_loadded = 1

" check fd binary name (needed because it's called fdfdind on ubuntu)
" Then check if it's installed
if system('which fd')[0] ==# '/'
    let g:goto_header_fd_binary_name = 'fd'
elseif system('which fdfind')[0] ==# '/'
    let g:goto_header_fd_binary_name = 'fdfind'
else
    echoerr "fd not found, please install it"
    finish
endif

command! GotoHeader :call goto_header#GotoHeader()
command! GotoHeaderSwitch :call goto_header#Switch()
command! GotoHeaderDirect :call goto_header#Direct()
