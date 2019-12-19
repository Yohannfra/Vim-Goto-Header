" vim plugin to go to header super quickly
" Assouline Yohann
" October 2019

if exists('g:goto_header_loadded')
    finish
endif
let g:goto_header_loadded = 1

command! GotoHeader :call goto_header#GotoHeader()
command! GotoHeaderSwitch :call goto_header#Switch()
command! GotoHeaderDirect :call goto_header#Direct()
