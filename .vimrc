"lets are listed blow 
let mapleader   = "," 
let g:mapleader = "," 
"this sentence is used to enable the 256 colors int vim
set t_Co=256   
"*******blow this line are used by plugins********
"*******blow this line are used by plugins********
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"alternatively, pass a path where vundle should install plugins
"call vundle#begin('~/some/path/here')

"let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"配色
Plugin 'altercation/vim-colors-solarized'  
syntax enable
let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai 

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'

" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
"Plugin 'ascenator/L9', {'name': 'newL9'}
"Plugin 'Solarized'


"this plugin is used to find file fastly;
"you can use Ctrl + p to start it
Plugin 'ctrlp.vim'
set wildignore+=*/temp*,*.so,*.swp,*.zip,*.deb      "ignore this files


"this plugin provide an overview of the structure of source code files
Plugin 'taglist.vim'
filetype on 
nnoremap <Leader>tl :TlistToggle<CR>
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Show_One_File      = 1  " 不同时显示多个文件的tag，只显示当前文件的
let Tlist_WinWidt            = 10 " 设置taglist的宽度
let Tlist_Exit_OnlyWindow    = 1  " 如果taglist窗口是最后一个窗口，则退出vim
" let Tlist_Use_Right_Window = 1
" 在右侧窗口中显示taglist窗口
let Tlist_Use_Left_Windo     = 1  " 在左侧窗口中显示taglist窗口

"this plugin is used to align code
Plugin 'godlygeek/tabular'
nmap <Leader>a= :Tabularize /=/l1<CR>
imap <Leader>a= :Tabularize /=/l1<CR>

"this plugin is used to show ultimate statusline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:Powerline_symbols='fancy'
let g:airline_powerline_fonts=0
set laststatus=2

"this plugin is used to complete automaticaly
Plugin 'shougo/neocomplete'
Plugin 'shougo/neosnippet'
Plugin 'shougo/neosnippet-snippets'


"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'


"this plugin is used to check syntax
Plugin 'scrooloose/syntastic'
set statusline+=%#wainingmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list            = 1
let g:syntastic_check_on_open            = 1
let g:syntastic_check_on_wq              = 0

highlight SyntasticError guibg=#2f0000
highlight SyntasticWarning guibg=#000000


" Show blanks as dot
Plugin 'Yggdroot/indentLine'
let g:indentLine_setColors = 0


" Plugin for golang
Plugin 'fatih/vim-go'


Plugin 'scrooloose/nerdtree'
let NERDTreeWinPos  = 'right'
let NERDTreeWinSize = 30
map <F2> :NERDTreeToggle<CR>
" All of your Plugins must be added before the following line
" All of your Plugins must be added before the following line
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"************ Put your non-Plugin stuff after this line***************
"************* Put your non-Plugin stuff after this line***************
"************** Put your non-Plugin stuff after this line***************

highlight Search term=standout ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
highlight Comment ctermfg=6
"nmap are listed blow 
nmap <leader>w :w<CR>
nmap <leader>q :q<CR>
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l

"imap are listed bolw
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-h> <Left>
imap <C-l> <right>
imap ;; <ESc>

"sets are listed blow
set number
set tabstop =4
set hlsearch
set softtabstop =4
set shiftwidth =4
set tabstop=4
"set autoindent 4
