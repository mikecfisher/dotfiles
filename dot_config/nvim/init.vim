" Minimal NeoVim Configuration with Palenight

" Core settings
set nocompatible
set synmaxcol=200
set lazyredraw
set ttyfast

" Install plugins
call plug#begin('~/.config/nvim/plugged')
Plug 'drewtempelmeyer/palenight.vim'
call plug#end()

" Theme setup
set termguicolors
set background=dark
colorscheme palenight

" Basic UI
set number
set relativenumber
set signcolumn=yes
set noshowmode
set cmdheight=1

" Performance optimizations
set updatetime=300
set timeoutlen=500
set ttimeoutlen=10
set regexpengine=1
syntax sync minlines=100

" Indentation (2-space)
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent

" Search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Window behavior
set splitbelow
set splitright

" System integration
set clipboard+=unnamedplus

" ===== Key Mappings =====
let mapleader=" "

" Escape with jk
inoremap jk <Esc>

" Move 5 lines at a time
nnoremap J 5j
nnoremap K 5k

" Window navigation with Ctrl+hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Split windows
nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>s :split<CR>

" Tab management
nnoremap <Leader>tt :tabnew<CR>
nnoremap <Leader>tn :tabnext<CR>
nnoremap <Leader>tp :tabprev<CR>
nnoremap <Leader>to :tabo<CR>

" Clear search highlight
nnoremap <silent> <Esc> :noh<CR>

" Quick syntax toggle for large files
nnoremap <leader>z :if exists("g:syntax_on") <Bar> syntax off <Bar> else <Bar> syntax enable <Bar> endif<CR>

" NeoVim-specific settings
if has('nvim')
  " Better terminal experience
  autocmd TermOpen * setlocal nonumber norelativenumber
  " Exit terminal mode with Escape
  tnoremap <Esc> <C-\><C-n>
  " Exit terminal mode with jk too
  tnoremap jk <C-\><C-n>
endif

" ===== First-Time Install Warning =====
if !filereadable(expand('~/.config/nvim/plugged/palenight.vim/colors/palenight.vim'))
  echom "Palenight theme not found!"
  echom "Run :PlugInstall to install plugins"
endif
