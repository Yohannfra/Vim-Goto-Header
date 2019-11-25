" vim plugin to go to header super quickly
" Assouline Yohann
" October 2019

function! s:GetHearderName(current_line)
    if stridx(a:current_line, "#include") == -1
        echo "No header detected in this line"
        return -1
    endif
    let l:current_line = a:current_line[8:]
    if stridx(l:current_line, "\"") != -1
        let l:current_line = substitute(l:current_line, '"', '', 'g')
    elseif stridx(l:current_line, '<') != -1 && stridx(l:current_line, '>') != -1
        let l:current_line = substitute(l:current_line, '<', '', 'g')
        let l:current_line = substitute(l:current_line, '>', '', 'g')
    else
        echo "Invalid line : " . l:current_line
        return -1
    endif

    while 1
        let l:index = stridx(l:current_line, "/")
        if l:index == -1
            break
        endif
        let s:path = s:path . l:current_line[0:l:index]
        let l:current_line = l:current_line[l:index + 1:]
    endwhile
    return l:current_line
endfunction

function! s:CheckConfigVals()
    if !exists("g:goto_header_includes_dirs")
        let g:goto_header_includes_dirs = [".", "/usr/include", "..", "~"]
    endif
    if !exists('g:goto_header_use_find')
        let g:goto_header_use_find = 0
    endif
    if !exists('g:goto_header_excludes_dirs')
        let g:goto_header_excludes_dirs = []
    endif
    if !exists('g:goto_header_open_in_new_tab')
        let g:goto_header_open_in_new_tab = 0
    endif
    if !exists("g:goto_header_search_flags")
        if g:goto_header_use_find
            let g:goto_header_search_flags = "-type f"
        else
            let g:goto_header_search_flags = "-t f -s"
        endif
    endif
endfunction

function! s:OpenFile(fp)
    if g:goto_header_open_in_new_tab
        execute ":tabedit " . a:fp
    else
        execute ":e " . a:fp
    endif
endfunction

function! GotoHeader()
    let l:current_line = substitute(getline('.'), ' ', '', 'g')
    let s:path = ""
    call s:CheckConfigVals()

    let l:current_line = s:GetHearderName(l:current_line)
    if l:current_line == -1
        return
    endif

    " if stridx(current_line, "+") != -1  " TODO
        " let current_line = substitute(current_line, '+', '\\+', 'g')
    " endif

    " Replace . with \. (because fd use regex)
    let l:current_line = substitute(l:current_line, '\.', '\\.', 'g')
    " Delete CLRF
    let l:current_line = substitute(l:current_line, '', '', 'g')

    if g:goto_header_use_find == 0
        let l:exclude_command = " "
        for l:dir in g:goto_header_excludes_dirs
            let l:exclude_command = l:exclude_command . "--exclude " . l:dir . ' '
        endfor
    endif

    let l:info_find = []
    for l:dir in g:goto_header_includes_dirs
        if g:goto_header_use_find == 0
            let l:info_find = systemlist('fd -L ' . g:goto_header_search_flags . l:exclude_command .' ^' . l:current_line . '$ ' . l:dir . ' 2> /dev/null')
        else
            let l:info_find = systemlist('find -L ' . l:dir . ' ' .  g:goto_header_search_flags . ' -name ' . l:current_line . ' 2> /dev/null')
        endif
        if len(l:info_find) != 0
            break
        endif
    endfor
    if len(l:info_find) != 0
        if len(l:info_find) == 1
            call s:OpenFile(l:info_find[0])
            return
        endif

        let c = 0
        for i in l:info_find
            if stridx(i, s:path) != -1
                echo c . " :  " . i
                let c += 1
            else
                call remove(l:info_find, c)
            endif
        endfor

        if c == 1
            call s:OpenFile(l:info_find[0])
            return
        endif
        let l:index = input("Select the file you want : ")
        if len(l:index) == 0
            return
        endif
        let l:index = str2nr(l:index, 10)
        if l:index > c
            echo "\n"
            echoerr "Invalid index : " . l:index
            return
        endif
            call s:OpenFile(l:info_find[l:index])
    else
        echo "Couldn't find " . l:current_line
    endif
endfunction

command! GotoHeader execute GotoHeader()
