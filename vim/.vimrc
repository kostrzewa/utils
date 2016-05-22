set smartindent
" visually differentiate between tabs and spaces, use spaces instead of tab
" characters
" tabs are displayed as 8 spaces
set tabstop=8
" tab in insert mode creates two spaces
set softtabstop=2
" >> and << create two spaces
set shiftwidth=2
" spaces are used instead of tabs
set expandtab

set cursorline
set ruler

vnoremap y "aY
noremap p "aP
vmap r "_dP

set pastetoggle=<F10>

let g:indent_guides_start_level=1
let g:indent_guides_enable_on_vim_startup=1
let indent_guides_auto_colors = 0

filetype plugin indent on
syntax on

set t_Co=256
colorscheme ron  
set cursorline
" dark blue cursor line marker
hi CursorLine ctermbg=17 cterm=none 

autocmd BufReadPost * :IndentGuidesEnable
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=237
