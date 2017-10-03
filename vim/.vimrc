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
Plug 'fsharp/vim-fsharp', {
    \ 'for': 'fsharp',
    \ 'do': 'make fsautocomplete',
    \}
Plug 'itchyny/lightline.vim'
Plug 'jelera/vim-javascript-syntax'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'Raimondi/delimitMate'
Plug 'Valloric/YouCompleteMe', {
    \ 'do': './install.py --clang-completer --omnisharp-completer --tern-completer --system-libclang'
    \}
Plug 'junegunn/fzf', {
    \ 'dir': '~/.fzf',
    \ 'do': './install --all',
    \}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-obsession'
Plug 'tmhedberg/SimpylFold'
Plug 'PeterRincker/vim-argumentative'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
call plug#end()

syntax enable
set term=xterm-256color
colorscheme nord
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set wildmenu
set incsearch
set hlsearch
set autoindent
"Both absolute and relative line numbers
set relativenumber
set number

map <silent> <C-N> :silent noh<CR>

au FileType py set autoindent
au FileType py set smartindent

"List chars
noremap <F3> :set list!<CR>
set list
set listchars=tab:→\ ,eol:↲,trail:•

"ALE settings
let g:ale_open_list = 1
let g:ale_list_window_size = 5
let g:ale_linters = {
    \ 'javascript': ['eslint'],
    \}
let g:ale_python_flake8_args = "--ignore=E501"
let g:ale_python_mypy_options = "--check-untyped-defs --strict-optional --warn-return-any --follow-imports=normal --incremental"
let g:ale_echo_cursor = 0

highlight clear ALEErrorSign
highlight clear ALEWarningSign

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

map <F5> :Error<CR>
map <F6> :lclose<CR>
map ]1 :call WrapCommand('down', 'l')<CR>
map [1 :call WrapCommand('up', 'l')<CR>

"Python autopep8 formatting with gq
au FileType python setlocal formatprg=autopep8\ -

" YouCompleteMe settings
let g:ycm_semantic_triggers = {
    \ 'fsharp': ["."],
    \ 'html': ["</"],
    \ 'htmldjango': ["</", "{{", "{%"],
    \ }
let g:ycm_python_binary_path = 'python'
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

" Lightline settings
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

let g:lightline = {
    \ 'colorscheme': 'nord',
    \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
    \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3"},
    \ 'active': {
    \   'left': [ [ 'mode', 'paste'],
    \             [ 'fugitive', 'filename' ] ],
    \   'right': [ [ 'ale', 'lineinfo' ],
    \              [ 'percent' ],
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
    \   'ale': 'LightLineAle',
    \ },
    \ 'component_type': {
    \   'ale': 'error',
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

function! LightLineAle()
    return ale#statusline#Status()
endfunction

augroup UpdateAleLightLine
    autocmd!
    autocmd User ALELint call lightline#update()
augroup END

"FZF settings
set wildignore+=*/node_modules/*
noremap <C-P> :Files<cr>

let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"
"let g:syntastic_ocaml_checkers = ['merlin']

set laststatus=2
set noshowmode
