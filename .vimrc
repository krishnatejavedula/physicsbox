" █░█ █ ▄▄ █ █▀▄▀█ █▀█ █▀█ █▀█ █░█ █▀▀ █▀▄
" ▀▄▀ █ ░░ █ █░▀░█ █▀▀ █▀▄ █▄█ ▀▄▀ ██▄ █▄▀
" vim:fileencoding=utf-8:foldmethod=marker

" =============================================================
" {{{ Plugins
" =============================================================

" Auto-install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/autoload/plugged')

  " Themes
  Plug 'morhetz/gruvbox'
  Plug 'dracula/vim', { 'as': 'dracula' }
  Plug 'arcticicestudio/nord-vim'
  Plug 'jnurmine/zenburn'

  " UI
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'mhinz/vim-startify'
  Plug 'preservim/nerdtree'
  Plug 'ryanoasis/vim-devicons'

  " Editor
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-fugitive'
  Plug 'airblade/vim-gitgutter'
  Plug 'raimondi/delimitmate'
  Plug 'machakann/vim-highlightedyank'
  Plug 'ntpeters/vim-better-whitespace'

call plug#end()

" }}}
" =============================================================
" {{{ General Settings
" =============================================================

set nocompatible
syntax on
filetype plugin indent on

colorscheme dracula

set encoding=utf-8
set fileencoding=utf-8
set fileformats=unix,dos,mac

set hidden
set history=10000
set updatetime=300
set timeoutlen=500
set confirm
set mouse=a

" Appearance
set t_Co=256
set termguicolors
set background=dark
set cursorline
set laststatus=2
set showtabline=2
set noshowmode
set ruler
set showcmd
set wildmenu
set pumheight=10
set cmdheight=2
set number
set conceallevel=0

" Indentation
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set autoindent

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Splits
set splitbelow
set splitright

" Folding
set foldmethod=marker
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo

" Spelling
set spell
set spelllang=en_us
set spellfile=~/.vim/spell/en.utf-8.add
set complete+=kspell
set completeopt=menuone,longest

" Clipboard
set clipboard+=unnamedplus

" Misc
set backspace=indent,eol,start
set iskeyword+=-
set scrolloff=8

" }}}
" =============================================================
" {{{ Swap, Backup and Undo
" =============================================================

set swapfile
set undofile
set backup
set backupdir=$HOME/.cache/vim/tmp/backup
set dir=$HOME/.cache/vim/tmp/swap
set viewdir=$HOME/.cache/vim/tmp/view
set undodir=$HOME/.cache/vim/tmp/undo
set viminfo+=n~/.cache/vim/tmp/viminfo

if !isdirectory(&backupdir) | call mkdir(&backupdir, 'p', 0700) | endif
if !isdirectory(&dir)       | call mkdir(&dir, 'p', 0700)       | endif
if !isdirectory(&viewdir)   | call mkdir(&viewdir, 'p', 0700)   | endif
if !isdirectory(&undodir)   | call mkdir(&undodir, 'p', 0700)   | endif

" }}}
" =============================================================
" {{{ Cursor Shape
" =============================================================

let &t_SI.="\e[5 q"  " INSERT  — blinking bar
let &t_SR.="\e[4 q"  " REPLACE — solid underscore
let &t_EI.="\e[1 q"  " NORMAL  — blinking block

" }}}
" =============================================================
" {{{ Plugin Settings
" =============================================================

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#whitespace#enabled = 0
let g:airline_left_sep  = "\uE0B8"
let g:airline_right_sep = "\uE0BA"
let g:airline_left_alt_sep  = "\ue0b9"
let g:airline_right_alt_sep = "\ue0bb"

" NERDTree
let NERDTreeShowHidden = 1
let g:NERDTreeWinPos   = "right"

" Startify
let g:startify_custom_header = [
  \'',
  \'   █░█ █ ▄▄ █ █▀▄▀█ █▀█ █▀█ █▀█ █░█ █▀▀ █▀▄',
  \'   ▀▄▀ █ ░░ █ █░▀░█ █▀▀ █▀▄ █▄█ ▀▄▀ ██▄ █▄▀',
  \'   PhysicsBox',
  \'',
  \ ]

let g:startify_files_number       = 10
let g:startify_enable_special     = 0
let g:startify_session_autoload   = 1
let g:startify_session_persistence = 1
let g:startify_session_delete_buffers = 1
let g:startify_session_dir        = $HOME . '/.cache/vim/sessions'

let g:startify_list_order = [
  \ ['   Recent files:'],   'files',
  \ ['   Sessions:'],       'sessions',
  \ ['   Bookmarks:'],      'bookmarks',
  \ ]

let g:startify_bookmarks = [
  \ { 'b': '~/.bashrc'  },
  \ { 'v': '~/.vimrc'   },
  \ ]

" vim-devicons
let g:webdevicons_enable                  = 1
let g:webdevicons_enable_nerdtree         = 1
let g:webdevicons_enable_startify         = 1
let g:webdevicons_enable_airline_tabline  = 1
let g:webdevicons_enable_airline_statusline = 1

function! StartifyEntryFormat()
  return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
endfunction

" better-whitespace
let g:better_whitespace_guicolor = '#d8dee9'
autocmd User Startified DisableWhitespace

" }}}
" =============================================================
" {{{ Keybindings
" =============================================================

let g:mapleader = "\<Space>"

" Common command typos
cnoreabbrev W  w
cnoreabbrev Q  q
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev Q! q!
cnoreabbrev W! w!

" Escape shortcuts
inoremap jk <Esc>
inoremap kj <Esc>

" Save / quit
nnoremap <C-s> :w<CR>
nnoremap <C-Q> :wq!<CR>

" Visual lines
noremap j gj
noremap k gk

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window resize with Alt+hjkl
noremap <silent> <M-h> :vertical resize +3<CR>
noremap <silent> <M-l> :vertical resize -3<CR>
noremap <silent> <M-k> :resize +3<CR>
noremap <silent> <M-j> :resize -3<CR>

" Splits
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

" Tab navigation
nnoremap <Tab>   gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

" Better indenting in visual mode
vnoremap < <gv
vnoremap > >gv

" Completion navigation
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Toggle line numbers
nnoremap <silent> <leader>l :set relativenumber! <bar> set nu!<CR>

" Fold toggle
nnoremap <expr> <Leader>ff &foldlevel ? 'zM' : 'zR'
nnoremap <expr> <leader>f  foldclosed('.') != -1 ? 'zO' : 'zc'

" NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>r :NERDTreeFind<CR>

" Startify
nnoremap <leader>sv :vsp <bar> Startify<CR>
nnoremap <leader>st :tabnew <bar> Startify<CR>

" }}}
