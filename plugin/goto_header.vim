" vim plugin to go to header super quickly
" Assouline Yohann
" October 2019

if exists('g:goto_header_loadded')
    finish
endif
let g:goto_header_loadded = 1

let which_fd = system('which fd')[0]
let which_fdfind = system('which fdfind')[0]

" check fd binary name (needed because it's called fdfdind on ubuntu)
" Then check if it's installed
if (which_fd ==# '/' || which_fd ==#'C')
    let g:goto_header_fd_binary_name = 'fd'
elseif (which_fdfind ==# '/' || which_fdfind ==#'C')
    let g:goto_header_fd_binary_name = 'fdfind'
else
    echoerr "fd not found, please install it"
    finish
endif

command! GotoHeader :call goto_header#GotoHeader()
command! GotoHeaderSwitch :call goto_header#Switch()
command! GotoHeaderDirect :call goto_header#Direct()
