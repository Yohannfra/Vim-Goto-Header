# Vim Goto-Header
Vim Goto-Header is a plugin I made to quickly jump to header files with vim/neovim.\
It can be use for both c or cpp.

Example :\
![alt text](.github/gif2.gif "Utilisation example")

## Dependencies
By default Goto-Header uses [fd](https://github.com/sharkdp/fd) (a find alternative) to look for headers.\
To install it on your system see : https://github.com/sharkdp/fd#installation \
If you want to use find instead of fd refer to the [configuration](#Configuration) section.

## Installation

### Using Plug
```
Plug 'Yohannfra/Vim-Goto-Header'
```

### Manual installation
```
git clone https://github.com/Yohannfra/Vim-Goto-Header/ ~/.vim/plugin/
```

## Configuration

#### Find utility
To use find instead of fd just put this line in your .vimrc
```vim
let g:goto_header_use_find = 1 " By default it's value is 0
```

#### Directories
By default the script will look in those directories (in this order):
- .
- /usr/include
- ..
- ~

To change the directories or the order you put this in your .vimrc
```vim
let g:goto_header_includes_dirs = ["DIR1", "DIR2", "DIR3.", "DIR4"]

" example:
let g:goto_header_includes_dirs = [".", "/usr/include", "..", "~"]
```

#### Flags

Both fd and find use -L flag (follow symlink). You can't change it using the following lines.

You can customize other fd/find flags by putting this in your .vimrc
```vim
let g:goto_header_fd_command = "fd -t f -s" " Use any flag you want except -L
" or if you want to use find
let g:goto_header_search_flags = "-type f" " Use any flag you want except -L
```

#### By default

The default configuration is the following one:
```vim
let g:goto_header_includes_dirs = [".", "/usr/include", "..", "~"]
let g:goto_header_use_find = 0      " keep using fd
let g:goto_header_search_flags = "-t f -s"
```

## Usage

put the following line in your .vimrc to map F12
```vim
nnoremap <F12> :GotoHeader <CR>
imap <F12> <Esc>:GotoHeader <CR>
```

Now you'll just need to press F12 on a line like one of those and it will open the corresponding file in a new tab
```c
#include <stdio.h>
#include "my_header.hpp"
```

If Vim Goto-Header finds more than one header it will show you a little prompt and you'll have
to chose which one.

![alt text](.github/prompt_vimgotoheader.png "Prompt example")
