if has('vim_starting')
    if &compatible
        set nocompatible
    endif
    
    set rtp+=~/.vim/bundle/neobundle.vim/
endif

let g:neobundle#install_process_timeout = 1500

call neobundle#begin(expand('~/.vim/bundle'))
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'tpope/vim-fugitive'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'fsharp/vim-fsharp', {
    \ 'description': 'F# support for vim',
    \ 'lazy': 1,
    \ 'autoload' : {'filetypes': 'fsharp'},
    \ 'build': {
    \   'unix': 'make fsautocomplete'
    \ },
    \ 'build_commands': ['curl', 'make', 'mozroots', 'touch', 'unzip'],
    \}
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'Valloric/YouCompleteMe', {
    \ 'build': {
    \   'unix': './install.sh --clang-completer --system-libclang --omnisharp-completer',
    \   }
    \}
NeoBundle 'marijnh/tern_for_vim'
NeoBundle 'kien/ctrlp.vim'
call neobundle#end()

syntax enable
set term=xterm-256color
set background=dark
colorscheme solarized
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set number
set wildmenu
set incsearch
set hlsearch
set autoindent
NeoBundleCheck

map <silent> <C-N> :silent noh<CR>

au FileType py set autoindent
au FileType py set smartindent

"NERDTree Settings
map <F2> :NERDTreeToggle<CR>
map <F3> :NERDTreeFind<CR>
let NERDTreeIgnore = ['\.pyc$']

"Syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height=5
let g:syntatstic_html_tidy_exec = 'tidy'

map <F5> :Error<CR>
map <F6> :lclose<CR>
map ]1 :lnext<CR>
map [1 :lprevious<CR>


" YouCompleteMe settings
let g:ycm_semantic_triggers = {
    \ 'fsharp': ["."],
    \ }

" Lightline settings
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

let g:lightline = {
    \ 'colorscheme': 'solarized',
    \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
    \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3"},
    \ 'active': {
    \   'left': [ [ 'mode', 'paste'],
    \             [ 'fugitive', 'filename' ] ],
    \   'right': [ [ 'syntastic', 'lineinfo' ],
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
    \   'syntastic': 'SyntasticStatuslineFlag',
    \ },
    \ 'component_type': {
    \   'syntastic': 'error',
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

augroup AutoSyntastic
    autocmd!
    autocmd BufWritePost *.c,*.cpp,*.py call s:syntastic()
augroup END

function! s:syntastic()
    SyntasticCheck
    call lightline#update()
endfunction

set laststatus=2
set noshowmode
