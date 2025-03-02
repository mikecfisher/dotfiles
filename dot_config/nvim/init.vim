" Minimal NeoVim Configuration with Palenight

" Core settings
set nocompatible
set synmaxcol=200
set lazyredraw
set ttyfast
set mouse=a
set hidden
set nobackup
set nowritebackup

" Install plugins
call plug#begin('~/.config/nvim/plugged')
" Theme
Plug 'drewtempelmeyer/palenight.vim'

" File navigation
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" Fuzzy finding/searching
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }

" Language support
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Improved syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Status line
Plug 'nvim-lualine/lualine.nvim'

" Git integration
Plug 'lewis6991/gitsigns.nvim'
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

" File explorer mappings
nnoremap <Leader>e :NvimTreeToggle<CR>
nnoremap <Leader>f :NvimTreeFindFile<CR>

" Telescope mappings
nnoremap <Leader>ff <cmd>Telescope find_files<CR>
nnoremap <Leader>fg <cmd>Telescope live_grep<CR>
nnoremap <Leader>fb <cmd>Telescope buffers<CR>
nnoremap <Leader>fh <cmd>Telescope help_tags<CR>

" LSP mappings
nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <Leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <Leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <Leader>d <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap [d <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap ]d <cmd>lua vim.diagnostic.goto_next()<CR>

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
  echom "Plugins not found!"
  echom "Run :PlugInstall to install plugins"
endif

" ===== Plugin Configurations =====

" Initialize Lua configurations
lua << EOF
-- File explorer setup
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

-- Telescope setup
require('telescope').setup{
  defaults = {
    file_ignore_patterns = {"node_modules", ".git/"},
    mappings = {
      i = {
        ["<Esc>"] = require('telescope.actions').close
      },
    }
  }
}

-- TreeSitter setup
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "typescript", "javascript", "tsx", "json", "html", "css", "lua", "vim" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- LSP setup
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- TypeScript setup
local lspconfig = require('lspconfig')
local ts_server = lspconfig.ts_ls or lspconfig.tsserver
if ts_server then
  ts_server.setup{
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      -- Disable formatting if you prefer prettier
      client.server_capabilities.document_formatting = false
    end
  }
else
  vim.notify("TypeScript language server not found in lspconfig. Check your nvim-lspconfig installation and version.", vim.log.levels.ERROR)
end

-- Completion setup
local cmp = require'cmp'
local luasnip = require'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Status line setup
require('lualine').setup {
  options = {
    theme = 'palenight',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  }
}

-- Git integration
require('gitsigns').setup()
EOF

" Restore K for navigation after LSP setup
nnoremap <Leader>K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap K 5k

" Check if TypeScript language server is installed
if !executable('typescript-language-server')
  echom "TypeScript Language Server not found!"
  echom "Run: npm install -g typescript-language-server typescript"
endif
