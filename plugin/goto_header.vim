" vim plugin to go to header super quickly
" Assouline Yohann
" October 2019

function! Strip(input_string)
    return substitute(a:input_string, ' ', '', 'g')
endfunction

function! GotoHeader()
    let current_line = Strip(getline('.'))

    if !exists("g:goto_header_includes_dirs")
        let g:goto_header_includes_dirs = [".", "/usr/include", "..", "~"]
    endif
    if !exists('g:goto_header_use_find')
        let g:goto_header_use_find = 0
    endif
    if !exists('g:goto_header_excludes_dirs')
        g:goto_header_excludes_dirs = []
    endif
    if !exists("g:goto_header_search_flags")
        if g:goto_header_use_find
            let g:goto_header_search_flags = "-type f"
        else
            let g:goto_header_search_flags = "-t f -s"
        endif
    endif
    " Some error handling
    if stridx(current_line, "#include") == -1
        echo "No header detected in this line"
        return
    endif
    let current_line = current_line[8:]
    if stridx(current_line, "\"") != -1
        let current_line = substitute(current_line, '"', '', 'g')
    elseif stridx(current_line, '<') != -1 && stridx(current_line, '>') != -1
        let current_line = substitute(current_line, '<', '', 'g')
        let current_line = substitute(current_line, '>', '', 'g')
    else
        echo "Invalid line : " . current_line
        return
    endif

    while 1
        let index = stridx(current_line, "/")
        if index == -1
            break
        endif
        let current_line = current_line[index + 1:]
    endwhile

    " if stridx(current_line, "+") != -1  " TODO
        " let current_line = substitute(current_line, '+', '\\+', 'g')
    " endif

    " Replace . with \. (because fd use regex)
    let current_line = substitute(current_line, '\.', '\\.', 'g')
    " Delete CLRF
    let current_line = substitute(current_line, '', '', 'g')

    if g:goto_header_use_find == 0
        let exclude_command = " "
        for dir in g:goto_header_excludes_dirs
            let exclude_command = exclude_command . "--exclude " . dir . ' '
        endfor
    endif

    let info_find = []
    for dir in g:goto_header_includes_dirs
        if g:goto_header_use_find == 0
            let info_find = systemlist('fd -L ' . g:goto_header_search_flags . exclude_command .' ^' . current_line . '$ ' . dir . ' 2> /dev/null')
        else
            let info_find = systemlist('find -L ' . dir . ' ' .  g:goto_header_search_flags . ' -name ' . current_line . ' 2> /dev/null')
        endif
        if len(info_find) != 0
            break
        endif
    endfor
    if len(info_find) != 0
        if len(info_find) == 1
            execute ":tabedit " . info_find[0]
            return
        endif

        let c = 0
        for i in info_find
            echo c . " :  " . i
            let c += 1
        endfor

        let index = input("Select the file you want : ")
        if len(index) == 0
            return
        endif
        let index = str2nr(index, 10)
        if index > c
            echo "\n"
            echoerr "Invalid index : " . index
            return
        endif
        execute ":tabedit " . info_find[index]
    else
        echo "Couldn't find " . current_line
    endif
endfunction

command! GotoHeader execute GotoHeader()
