set nocompatible

" Auto install vim-plug if not available
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'w0rp/ale'
Plug 'michaeljsmith/vim-indent-object'
Plug 'arcticicestudio/nord-vim'
Plug 'kamwitsta/nordisk'
Plug 'fsharp/vim-fsharp', {
    \ 'for': 'fsharp',
    \ 'do': 'make fsautocomplete',
    \}
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'jelera/vim-javascript-syntax'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'Raimondi/delimitMate'
Plug 'junegunn/fzf', {
    \ 'dir': '~/.fzf',
    \ 'do': './install --all',
    \}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-obsession'
Plug 'PeterRincker/vim-argumentative'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'cmugpi/vim-c0'
Plug 'easymotion/vim-easymotion'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-pyclang'
Plug 'ncm2/ncm2-jedi'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
if has('nvim')
    Plug 'jalvesaq/Nvim-R'
endif
Plug 'vim-pandoc/vim-pandoc-syntax'
call plug#end()

" Settings for true color and colorscheme
if has('vim')
    set term=xterm-256color
endif
set background=dark
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
colorscheme nordisk

syntax enable
filetype plugin indent on
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set wildmenu
set incsearch
set hlsearch
if has('nvim')
    set inccommand=nosplit
endif
set autoindent
"Both absolute and relative line numbers
set relativenumber
set number
set lazyredraw
set ttyfast
set hidden
set laststatus=2

" Ctrl + N to remove highlights
map <silent> <C-N> :silent noh<CR>

" Faster insert-to-normal mode
augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
augroup END

" Delay time for when vim uses fsync()
set updatetime=100

au FileType py set autoindent
au FileType py set smartindent
" Python Syntax highlighting from python-syntax
let g:python_highlight_all = 1

"List chars
noremap <F3> :set list!<CR>
set list
set listchars=tab:→\ ,eol:↲,trail:•

"ALE settings
let g:ale_open_list = 0
let g:ale_list_window_size = 5
let g:ale_linters = {
    \ 'javascript': ['eslint'],
    \ 'python': ['pyls']
    \}
let g:ale_python_flake8_args = "--ignore=E501"
let g:ale_python_mypy_options = "--check-untyped-defs --strict-optional --warn-return-any --follow-imports=normal --incremental"
let g:ale_echo_cursor = 1
let g:ale_completion_enabled = 0
let g:ale_pattern_options = {
            \   '.*\.json$': {'ale_enabled': 0},
            \   'fugitive:///*': {'ale_enabled': 0}
            \}
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '●'
noremap <F5> :ALEToggle<CR>
noremap <C-H> :ALEHover<CR>
nnoremap <silent> ]e :ALENextWrap<CR>
nnoremap <silent> [e :ALEPreviousWrap<CR>
highlight clear ALEErrorSign
highlight clear ALEWarningSign
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

set statusline=%{LinterStatus()}

" wrap :cnext/:cprevious and :lnext/:lprevious
function! WrapCommand(direction, prefix)
    if a:direction == "up"
        try
            execute a:prefix . "previous"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "last"
        catch /^Vim\%((\a\+)\)\=:E\%(776\|42\):/
        endtry
    elseif a:direction == "down"
        try
            execute a:prefix . "next"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "first"
        catch /^Vim\%((\a\+)\)\=:E\%(776\|42\):/
        endtry
    endif
endfunction

map <F6> :lclose<CR>
map ]1 :call WrapCommand('down', 'l')<CR>
map [1 :call WrapCommand('up', 'l')<CR>

"Python autopep8 formatting with gq
au FileType python setlocal formatprg=autopep8\ -

" Lightline settings
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

let g:lightline = {
    \ 'colorscheme': 'nordisk',
    \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
    \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3"},
    \ 'active': {
    \   'left': [ [ 'mode', 'paste'],
    \             [ 'fugitive', 'filename' ] ],
    \   'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
    \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
    \ },
    \ 'component_function': {
    \   'readonly': 'MyReadonly', 
    \   'modified': 'MyModified',
    \   'fugitive': 'MyFugitive', 
    \   'filename': 'MyFilename'
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype != "help" && &readonly)',
    \   'modified': '(&filetype != "help" && (&modified || !&modifiable))',
    \   'fugitive': '(exists("*fugitive#head") && "" != fugitive#head())'
    \ },
    \ 'component_expand': {
    \  'linter_checking': 'lightline#ale#checking',
    \  'linter_warnings': 'lightline#ale#warnings',
    \  'linter_errors': 'lightline#ale#errors',
    \  'linter_ok': 'lightline#ale#ok',
    \ },
    \ 'component_type': {
    \   'linter_checking': 'left',
    \   'linter_warnings': 'warning',
    \   'linter_errors': 'error',
    \   'linter_ok': 'left',
    \ }
    \ }

function! MyModified()
    if &filetype == "help"
        return ""
    elseif &modified
        return "+"
    elseif &modifiable
        return ""
    else
        return ""
    endif
endfunction

function! MyReadonly()
    if &filetype == "help"
        return ""
    elseif &readonly
        return "\ue0a2"
    else
        return ""
    endif
endfunction

function! MyFugitive()
    if exists('*fugitive#head')
        let _ = fugitive#head()
        return strlen(_) ? "\ue0a0" . ' ' . _ : ''
    endif
    return ''
endfunction

function! MyFilename()
    let fname = expand('%:t')
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
         \ ('' != fname ? fname : '[No Name]') .
         \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

"FZF settings
set wildignore+=*/node_modules/*
noremap <C-P> :Files<cr>

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }


"" [Buffers] Jump to the existing window if possible [Buffers] Jump to th
let g:fzf_buffers_jump = 1

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"

" C0 Settings
au FileType c0 setlocal shiftwidth=2 softtabstop=2 expandtab cindent colorcolumn=80
" For 15-122 Only
" au FileType c setlocal shiftwidth=2 softtabstop=2 expandtab cindent colorcolumn=80
au FileType c setlocal expandtab cindent colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=LightGray

" Netrw settings
let g:netrw_liststyle = 3   " Tree style view
let g:netrw_altv = 1        " Press v to open file on right split
let g:netrw_winsize = 70    " Netrw uses 30% of split only

" Easymotion settings
map <Leader> <Plug>(easymotion-prefix)

" Nvim-R settings
let R_in_buffer = 1
let R_term = "alacritty"
let R_rconsole_height = 10

"NCM2 settings
" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

"IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

let g:ncm2_pyclang#library_path = "/usr/lib64/libclang.so.6.0"

let g:LanguageClient_serverCommands = {
    \ 'r': ['R', '--slave', '-e', 'languageserver::run(debug="/home/eujing/rlanguageserver.debug.log")'],
    \ 'rmd': ['R', '--slave', '-e', 'languageserver::run()'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'javascript.jsx': ['javascript-typescript-stdio']
    \ }
