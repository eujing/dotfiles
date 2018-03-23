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
Plug 'bcicen/vim-vice'
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
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
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
Plug 'cmugpi/vim-c0'
call plug#end()

" Settings for true color and colorscheme
set term=xterm-256color
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
set autoindent
"Both absolute and relative line numbers
set relativenumber
set number

" Ctrl + N to remove highlights
map <silent> <C-N> :silent noh<CR>

" Faster insert-to-normal mode
augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
augroup END

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
    \ 'javascript': ['eslint']
    \}
" let g:ale_linter_aliases = {'c0': 'c'}
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

" Asyncomplete.vim settings
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)
let g:asyncomplete_remove_duplicates = 1
set completeopt+=preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Python LSP
if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

" Buffer autocompletion
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['c0'],
    \ 'blacklist': ['go, python'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ }))

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
highlight ColorColumn ctermbg=0 guibg=lightgrey

set laststatus=2
set noshowmode
