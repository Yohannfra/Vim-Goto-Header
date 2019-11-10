# Vim Goto-Header

## Installation

### Using Plug
```
Plug 'YohannFra/'
```

### Manual installation
```
git clone https://github.com/Yohannfra/ ~/.vim/plugin/
```

## Usage

put the following line in your .vimrc to map F12
```vim
nnoremap <F12> :GotoHeader <CR>
imap <F12> <Esc>:GotoHeader <CR>
```
