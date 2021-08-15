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
    if !exists("g:goto_header_search_flags")
        let g:goto_header_search_flags = "-t f -s"
    endif
    let g:goto_header_includes_dirs =
        \ get(g:, 'goto_header_includes_dirs',[".", "/usr/include", "..", "~"])
    let g:goto_header_excludes_dirs = get(g:, 'goto_header_excludes_dirs', [])
    let g:goto_header_open_in_new_tab = get(g:, 'goto_header_open_in_new_tab')
    let g:goto_header_use_shorter_path = get(g:, 'goto_header_use_shorter_path')
    let g:goto_header_associate_cpp_h = get(g:, 'goto_header_associate_cpp_h')
endfunction

function! s:OpenFile(fp)
    if g:goto_header_open_in_new_tab
        execute ":tabedit " . a:fp
    else
        execute ":e " . a:fp
    endif
endfunction

function! s:ShortenPath(path)
    if g:goto_header_use_shorter_path == 0
        return a:path
    endif
    let l:laslen = -1
    let l:path = a:path
    while len(l:path) > &columns - 5
        let shorten_path = ""  . l:path[0] ==# '/' ? '/' : ""
        let path_splitted = split(l:path, '/')
        for p in path_splitted
            if p !=# path_splitted[len(path_splitted) - 1]
                let shorten_path = shorten_path . p[0: len(p) - 2] . '/'
            else
                let shorten_path = shorten_path . p
            endif
        endfor
        let l:path = shorten_path
        if len(l:path) == l:laslen
            break
        endif
        let l:laslen = len(l:path)
    endwhile
    return l:path
endfunction

function! s:GetFindResult(current_line)
    " if stridx(current_line, "+") != -1  " TODO
        " let current_line = substitute(current_line, '+', '\\+', 'g')
    " endif

    " Replace . with \. (because fd use regex)
    let l:current_line = substitute(a:current_line, '\.', '\\.', 'g')
    " Delete CLRF
    let l:current_line = substitute(l:current_line, '', '', 'g')

    let l:exclude_command = " "
    for l:dir in g:goto_header_excludes_dirs
        let l:exclude_command = l:exclude_command . "--exclude " . l:dir . ' '
    endfor


    let l:info_find = []
    for l:dir in g:goto_header_includes_dirs
        let l:info_find = systemlist(g:goto_header_fd_binary_name . ' -L ' . g:goto_header_search_flags . l:exclude_command .' ^' . l:current_line . '$ ' . l:dir . ' 2> /dev/null')
        if len(l:info_find) != 0
            break
        endif
    endfor
    return info_find
endfunction

function! s:DisplayPrompt(info_find, current_line)
    let l:info_find = a:info_find
    if len(l:info_find) != 0
        if len(l:info_find) == 1
            call s:OpenFile(l:info_find[0])
            return
        endif

        let c = 0
        for i in l:info_find
            if stridx(i, s:path) != -1
                let i = s:ShortenPath(i)
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
        if l:index > c - 1
            echo "\n"
            echoerr "Invalid index : " . l:index
            return
        endif
            call s:OpenFile(l:info_find[l:index])
    else
        echo "Couldn't find " . a:current_line
    endif
endfunction

function! goto_header#GotoHeader()
    let l:current_line = substitute(getline('.'), ' ', '', 'g')
    let s:path = ""
    call s:CheckConfigVals()

    let l:current_line = s:GetHearderName(l:current_line)
    if l:current_line == -1
        return
    endif

    let l:info_find = s:GetFindResult(l:current_line)
    call s:DisplayPrompt(l:info_find, l:current_line)
endfunction

function! goto_header#Direct()
    let l:filename = input("Header name : ")
    let s:path = ""
    let l:info_find = s:GetFindResult(l:filename)
    call s:DisplayPrompt(l:info_find, l:filename)
endfunction

function! goto_header#Switch()
    call s:CheckConfigVals()
    let filename = expand('%:t')
    let found = 0
    let s:path = ""
    let extensions_dict = {
                \        ".*.cpp$" : (g:goto_header_associate_cpp_h) ? ".h" : ".hpp",
                \        ".*.hpp$" : ".cpp",
                \        ".*.c$" : ".h",
                \        ".*.h$" : ".c",
                \}

    for key in keys(extensions_dict)
        if match(filename, key) != -1
            let filename = filename[0:stridx(filename, '.') - 1] . extensions_dict[key]
            let found = 1
            break
        endif
    endfor
    if found
        let buf_exist = bufnr(filename)
        if buf_exist == -1
            let info_find = s:GetFindResult(filename)
            call s:DisplayPrompt(info_find, filename)
        else
            call s:OpenFile(bufname(filename))
        endif
    else
        echo "Can't switch from " . filename
    endif
endfunction
