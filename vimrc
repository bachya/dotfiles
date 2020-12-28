" Aaron Bach's .vimrc
"" vim:fdm=expr:fdl=0
""" General Settings
" Enable syntax highlighting:
syntax on
"
" Enable file type detection, indent files, and plugin files:
if has('autocmd')
	filetype plugin indent on
endif

" Copy indent to the new line:
set autoindent

" Allow `backspace` in insert mode:
set backspace=indent
set backspace+=eol
set backspace+=start

" When making a change, don't redisplay the line, and instead, put a `$` sign at the
" end of the changed text:
set cpoptions+=$

" Highlight Black's ideal line length + 1:
set colorcolumn=89

" Highlight the current line:
set cursorline
"
" Set directory for swap files:
set directory=~/.vim/swaps

" Use UTF-8 without BOM:
set encoding=utf-8 nobomb

" Allow for unsaved buffers:
set hidden

" Increase command line history:
set history=5000

" Ignore case in search patterns:
set ignorecase

" Highlight search pattern as it is being typed:
set incsearch

" Shorten the amount of time between re-renders:
set updatetime=750

" Do not redraw the screen while executing macros, registers and other commands that
" have not been typed:
set lazyredraw

" Use custom symbols to represent invisible characters:
set listchars=tab:▸\
set listchars+=trail:·
set listchars+=eol:↴
set listchars+=nbsp:_

" Enable extended regexp:
set magic

" Hide mouse pointer while typing:
set mousehide

" When using the join command, only insert a single space after a `.`, `?`, or
" `!`:
set nojoinspaces

" Kept the cursor on the same column:
set nostartofline

" Show line number:
set number

" Increase the minimal number of columns used for the `line number`:
set numberwidth=5

" Enable relative line numbers by default:
set relativenumber
"
" Report the number of lines changed:
set report=0
"
" Show cursor position:
set ruler

" When scrolling, keep the cursor 5 lines below the top and 5 lines above the
" bottom of the screen:
set scrolloff=5

" Avoid all the hit-enter prompts:
set shortmess=aAItW

" Show the command being typed:
set showcmd

" Show current mode:
set showmode
"
" Set the spellchecking language:
set spelllang=en_us

" Override `ignorecase` option if the search pattern contains uppercase
" characters:
set smartcase

" Limit syntax highlighting (this avoids the very slow redrawing when files
" contain long lines):
set synmaxcol=2500

" Set global <TAB> settings (http://vimcasts.org/e/2):
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

" Enable fast terminal connection:
set ttyfast
"
" Set directory for undo files:
set undodir=~/.vim/undos
"
" Automatically save undo history:
set undofile
"
" Allow cursor to be anywhere:
set virtualedit=all

" Disable beeping and window flashing:
set visualbell
set noerrorbells
set t_vb=

" Enable enhanced command-line completion (by hitting <TAB> in command mode,
" Vim will show the possible matches just above the command line with the
" first match highlighted):
set wildmode=longest,list,full
set wildmenu

" Allow windows to be squashed:
set winminheight=0

" Fixes plugins that require a version of Python not loaded dynamically
" https://stackoverflow.com/a/41733943
if has('python') " if dynamic py|py3, this line already activates python2.
    let s:python_version = 2
elseif has('python3')
    let s:python_version = 3
else
    let s:python_version = 0
endif

" Figure out the system Python for Neovim.
if exists("$VIRTUAL_ENV")
    let g:python3_host_prog=substitute(system("which -a python3 | head -n2 | tail -n1"), "\n", '', 'g')
else
    let g:python3_host_prog=substitute(system("which python3"), "\n", '', 'g')
endif

""" General Key Mappings
" Use a different mapleader (default is '\'):
let mapleader = ','

" Remap VIM 0 to first non-blank character:
map 0 ^

" Search and replace the word under the cursor:
nnoremap <leader>* :%s/<C-r><C-w>//<Left>

" Makes gj/gk move by virtual lines when used without a count, and by
" physical lines when used with a count. This is perfect in tandem with
" relative numbers:
" http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
nnoremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Make the opening of the `.vimrc` file easier:
nnoremap <leader>v :vsp $MYVIMRC<CR>

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss:
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Clear current search highlight:
nnoremap <silent> // :nohlsearch<CR>

" Make Y behave like other capitals:
nnoremap Y y$

" qq to record, Q to replay:
nnoremap Q @q
""" Backups
set nobackup
set nowb
set noswapfile
""" Buffers
" Navigate back and forth in buffers:
nnoremap <Tab> :bn<cr>
nnoremap <S-Tab> :bp<cr>

" Show an FZF list of buffers:
nnoremap ; :Buffers<cr>

" Delete the current buffer:
nnoremap <leader>bd :BD<cr>

" Delete all buffers _but_ the current one:
nnoremap <leader>bo :BufOnly<cr>

" Switch CWD to the directory of the open buffer:
nnoremap <leader>cd :cd %:p:h<cr>:pwd<cr>

" Return to last edit position when opening files:
autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\   exe "normal! g`\"" |
			\ endif

" Remember info about open buffers on close:
set viminfo^=%
""" Clipboard
" Use the system clipboard as the default register:
set clipboard=unnamed
if has('unnamedplus')
	set clipboard+=unnamedplus
endif
""" Editing
" http://vimcasts.org/episodes/soft-wrapping-text/
command! -nargs=* Wrap set wrap linebreak nolist
""" File Management
" Use ripgrep as the grep program:
set grepprg=rg\ -S\ --vimgrep
nnoremap <leader>gr :grep<space>

" Immediately open the QuickFix window after grepping:
autocmd QuickFixCmdPost grep nested cwindow

" :W and :Save will escape a file name and write it:
function! W(bang, filename) abort
	:exe "w".a:bang." ". fnameescape(a:filename)
endfunction
function! Save(bang, filename) abort
	:exe "save".a:bang." ". fnameescape(a:filename)
endfunction
command! -bang -nargs=* W :call W(<q-bang>, <q-args>)
command! -bang -nargs=* Save :call Save(<q-bang>, <q-args>)
""" Folding
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

" Quickly fold/unfold the fold under the cursor:
nnoremap <space><space> za
""" pbcopy/pbpaste
" https://gist.github.com/burke/5960455
function! PropagatePasteBufferToOSX() abort
	let @n=getreg("")
	call system('pbcopy-remote', @n)
	echo "done"
endfunction
command! PropagatePasteBufferToOSX :call PropagatePasteBufferToOSX()
""" Plugins
" Use vim-plug to manage plugins:
" https://github.com/junegunn/vim-plug
call plug#begin('~/.local/share/nvim/plugged')
" Speed up Vim by updating folds only when called for:
Plug 'Konfekt/FastFold'

" The ultimate snippet solution for Vim:
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" Display the indention levels with thin vertical lines:
Plug 'Yggdroot/indentLine'

" Shows a git diff in the 'gutter' (sign column):
Plug 'airblade/vim-gitgutter'

" Changes Vim working directory to project root (identified by presence of
" known directory or file):
Plug 'airblade/vim-rooter'

" Resizing the screen using arrow keys:
Plug 'breuckelen/vim-resize'

" Provides a completion function for Unicode glyphs:
Plug 'chrisbra/unicode.vim'

" Mapping for sorting a range of text:
Plug 'christoomey/vim-sort-motion'

" Seamless navigation between tmux panes and vim splits:
Plug 'christoomey/vim-tmux-navigator'

" Snazzy color theme:
Plug 'connorholyday/vim-snazzy'

" Vim motions on speed!
Plug 'easymotion/vim-easymotion'

" Perform all your vim insert mode completions with Tab:
Plug 'ervandew/supertab'

" Various extensions to incsearch:
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch.vim'

" Fugitive extension to manage and merge Git branches:
Plug 'idanarye/vim-merginal'

" A dark Vim/Neovim color scheme:
Plug 'joshdick/onedark.vim'

" Ease your git workflow within Vim:
Plug 'jreybert/vimagit'

" A command-line fuzzy finder:
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Extends " and @ to see the contents of registers:
Plug 'junegunn/vim-peekaboo'

" Plugin to toggle, display and navigate marks:
Plug 'kshenoy/vim-signature'

" Intellisense engine and LSP:
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Kills buffers without closing splits:
Plug 'qpkorr/vim-bufkill'

" Insert mode auto-completion for quotes, parens, brackets, etc.:
Plug 'raimondi/delimitmate'

" Extended f, F, t and T key mappings for Vim.
Plug 'rhysd/clever-f.vim'

"Yet Another Remote Plugin Framework for Neovim:
Plug 'roxma/nvim-yarp'

" A tree explorer plugin for vim:
Plug 'scrooloose/nerdtree'

" A collection of language packs for Vim:
Plug 'sheerun/vim-polyglot'

" A plugin to visualize your Vim undo tree:
Plug 'sjl/gundo.vim'

" Change code right in the quickfix window:
Plug 'stefandtw/quickfix-reflector.vim'

" A simple alignment operator for Vim:
Plug 'tommcdo/vim-lion'

" Easily search for, substitute, and abbreviate multiple variants of a word:
Plug 'tpope/tpope-vim-abolish'

" Easily comment stuff out:
Plug 'tpope/vim-commentary'

" Vim sugar for the UNIX shell commands that need it the most:
Plug 'tpope/vim-eunuch'

" The best Git wrapper of all time:
Plug 'tpope/vim-fugitive'

" Remaps . in a way that plugins can tap into it:
Plug 'tpope/vim-repeat'

" Quoting/parenthesizing made simple:
Plug 'tpope/vim-surround'

" Delete all the buffers except the current/named buffer:
Plug 'vim-scripts/BufOnly.vim'

" Replace text with the contents of a register:
Plug 'vim-scripts/ReplaceWithRegister'

" Check syntax (linting) and fix files asynchronously.
Plug 'w0rp/ale'

" Vim plugin that provides additional text objects:
Plug 'wellle/targets.vim'
call plug#end()
filetype on
""" Plugin: Ale
" Quickly lint the whole file:
nnoremap <leader>F :ALEFix<cr>

" Jump back and forth between linting errors:
nnoremap <silent> <C-p> :ALEPrevious<cr>
nnoremap <silent> <C-n> :ALENext<cr>

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'json': ['fixjson'],
\   'python': ['black'],
\   'xml': ['xmllint']
\}
let g:ale_linters = {
\   'python': ['flake8', 'pydocstyle', 'pylint']
\}

let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_echo_msg_warning_str = 'W'

" Only lint on save, not everytime something changes:
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
""" Plugin: clever-f.vim
let g:clever_f_across_no_line = 1
let g:clever_f_timeout_ms = 3000
""" Plugin: Color Scheme
" Enable full-color support:
set t_Co=256

" Use colors that look good on a dark background:
set background=dark

" Use this colorscheme:
silent! colorscheme snazzy
""" Plugin: EasyMotion
" Move to {char}:
nmap  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" Move to {char}{char}:
nmap s <Plug>(easymotion-overwin-f2)

" Move to line:
nmap <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word:
nmap  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" Move to search results:
nmap  / <Plug>(incsearch-easymotion-/)
nmap  ? <Plug>(incsearch-easymotion-?)
nmap  g/ <Plug>(incsearch-easymotion-stay)

" Allow search results be fuzzy:
function! s:config_easyfuzzymotion(...) abort
  return extend(copy({
  \   'converters': [incsearch#config#fuzzy#converter()],
  \   'modules': [incsearch#config#easymotion#module()],
  \   'keymap': {"\<CR>": '<Over>(easymotion)'},
  \   'is_expr': 0,
  \   'is_stay': 1
  \ }), get(a:, 1, {}))
endfunction
nnoremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())
""" Plugin: FZF
" Make it easy to open FZF results in splits:
let g:fzf_action = {'ctrl-s': 'split', 'ctrl-v': 'vsplit'}

" Set the session path:
let g:fzf_session_path = $HOME . '/.vim/sessions'

let g:fzf_layout = { 'window': 'botright new' }

" Toggle a file list
nnoremap <leader>t :Files<CR>

" Create a FZF-friendly grepping thing:
command! -bang -nargs=* Rg
\ call fzf#vim#grep(
\   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
\   <bang>0 ? fzf#vim#with_preview('up:60%')
\           : fzf#vim#with_preview('right:50%:hidden', '?'),
\   <bang>0)
nnoremap <leader>a :Rg<space>

""" Plugin: indentLine
let g:indentLine_faster = 1
let g:indentLine_color_term = 239
""" Plugin: lion-vim
let g:lion_squeeze_spaces = 1
""" Plugin: Markdown
let g:vim_markdown_conceal = 0
let g:vim_markdown_folding_disabled=1
""" Plugin: NERDTree
let g:NERDTreeMapActivateNode = "<F3>"
let g:NERDTreeMapPreview      = "<F4>"

nnoremap <silent> <C-\> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
""" Plugin: Supertab
let g:SuperTabDefaultCompletionType = 'context'
""" Plugin: UltiSnips
" Better key bindings for UltiSnipsExpandTrigger:
let g:UltiSnipsSnippetDirectories=["UltiSnips", "vim_snippets"]
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
""" Plugin: vim-fugitive
nnoremap <leader>gP :Gpull \| :Gpush<cr>
nnoremap <Leader>gb :Gblame<CR>
""" Plugin: vim-gitgutter
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_modified_removed = '<'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'

let g:gitgutter_override_sign_column_highlight = 1
highlight SignColumn guibg=bg
highlight SignColumn ctermbg=bg

nmap <Leader>ga <Plug>(GitGutterStageHunk)
nmap <Leader>gn <Plug>(GitGutterNextHunk)
nmap <Leader>gp <Plug>(GitGutterPrevHunk)
nmap <Leader>gu <Plug>(GitGutterUndoHunk)
""" Plugin: vim-merginal
nmap <Leader>gb :Merginal<CR>
""" Plugin: vimagit
let g:magit_discard_untracked_do_delete=1

nnoremap <leader>gs :Magit<CR>
""" Plugin: Vim Tmux Navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
""" Status Line
" Terminal types:
"   1) term  (normal terminals, e.g.: vt100, xterm)
"   2) cterm (color terminals, e.g.: MS-DOS console, color-xterm)
"   3) gui   (GUIs)

highlight ColorColumn
			\ term=NONE
			\ cterm=NONE  ctermbg=237    ctermfg=NONE
			\ gui=NONE    guibg=#073642  guifg=NONE

highlight CursorLine
			\ term=NONE
			\ cterm=NONE  ctermbg=235  ctermfg=NONE
			\ gui=NONE    guibg=#073642  guifg=NONE

highlight CursorLineNr
			\ term=bold
			\ cterm=bold  ctermbg=NONE   ctermfg=178
			\ gui=bold    guibg=#073642  guifg=#ff8700

highlight LineNr
			\ term=NONE
			\ cterm=NONE  ctermfg=241    ctermbg=NONE
			\ gui=NONE    guifg=#839497  guibg=#073642

highlight User1
			\ term=NONE
			\ cterm=NONE  ctermbg=237    ctermfg=Grey
			\ gui=NONE    guibg=#073642  guifg=#839496

highlight clear SignColumn

set statusline=
set statusline+=%1*            " User1 highlight
set statusline+=\ [%n]         " Buffer number

function! GetGitBranchName() abort
	let branchName = ''
	if exists('g:loaded_fugitive')
		let branchName = '[' . fugitive#head() . ']'
	endif
	return branchName
endfunction
set statusline+=\ %{GetGitBranchName()} " Git branch name

set statusline+=\ [%f]         " Path to the file
set statusline+=%m             " Modified flag
set statusline+=%r             " Readonly flag
set statusline+=%h             " Help file flag
set statusline+=%w             " Preview window flag
set statusline+=%y             " File type
set statusline+=[
set statusline+=%{&ff}         " File format
set statusline+=:
set statusline+=%{strlen(&fenc)?&fenc:'none'} " File encoding
set statusline+=]
set statusline+=%=             " Left/Right separator
set statusline+=%c             " File encoding
set statusline+=,
set statusline+=%l             " Current line number
set statusline+=/
set statusline+=%L             " Total number of lines
set statusline+=\ (%P)\        " Percent through file

" Example result:
"
"  [1] [master] [vim/vimrc][vim][unix:utf-8]            17,238/381 (59%)

set laststatus=2               " Always show the status line
