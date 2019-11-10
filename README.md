# Vim Goto-Header
Vim Goto-Header is a script i made to quickly jump to header files with vim.\
It can be use for both c or cpp.

Example :\
![alt text](.github/gif2.gif "Utilisation example")

## Dependencies
By default Goto-Header uses [fd](https://github.com/sharkdp/fd) (a find alternative) to look for headers.\
To install it on your system see : https://github.com/sharkdp/fd#installation \

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

You can customize the fd flags by putting this in your .vimrc
```vim
let g:goto_header_fd_command = "fd -t f -s -L" " Use any flag you want
```

## Usage

put the following line in your .vimrc to map F12
```vim
nnoremap <F12> :GotoHeader <CR>
imap <F12> <Esc>:GotoHeader <CR>
```

Now you'll just need to press F12 on a line like one of those and it will open it the corresponding file in a new tab
```c
#include <stdio.h>
#include "my_header.hpp"
```

If Vim Goto-Header finds more than one header it will show you a little prompt and you'll have
to chose which one.

![alt text](.github/prompt_vimgotoheader.png "Prompt example")
