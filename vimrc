" Aaron Bach's .vimrc
" vim:foldmethod=marker:foldlevel=99
" General Settings {{{
set nocompatible               " Don't make vim vi-compatibile
syntax on                      " Enable syntax highlighting
if has('autocmd')
	filetype plugin indent on
	"           │     │    └──── Enable file type detection
	"           │     └───────── Enable loading of indent file
	"           └─────────────── Enable loading of plugin files
endif
set autoindent                 " Copy indent to the new line

set backspace=indent           " ┐
set backspace+=eol             " │ Allow `backspace`
set backspace+=start           " ┘ in insert mode

set cpoptions+=$               " When making a change, don't
                               " redisplay the line, and instead,
                               " put a `$` sign at the end of
                               " the changed text
set colorcolumn=80             " Highlight certain column(s)
set cursorline                 " Highlight the current line
set directory=~/.vim/swaps     " Set directory for swap files
set encoding=utf-8 nobomb      " Use UTF-8 without BOM
set hidden                     " Allow for unsaved buffers
set history=5000               " Increase command line history
set ignorecase                 " Ignore case in search patterns

set incsearch                  " Highlight search pattern as
                               " it is being typed

set updatetime=750
set lazyredraw                 " Do not redraw the screen while
                               " executing macros, registers
                               " and other commands that have
                               " not been typed

set listchars=tab:▸\           " ┐
set listchars+=trail:·         " │ Use custom symbols to
set listchars+=eol:↴           " │ represent invisible characters
set listchars+=nbsp:_          " ┘

set magic                      " Enable extended regexp
set mousehide                  " Hide mouse pointer while typing

set nojoinspaces               " When using the join command,
                               " only insert a single space
                               " after a `.`, `?`, or `!`

set nostartofline              " Kept the cursor on the same column
set number                     " Show line number

set numberwidth=5              " Increase the minimal number of
                               " columns used for the `line number`

set relativenumber             " Enable relative line numbers by default
set report=0                   " Report the number of lines changed
set ruler                      " Show cursor position

set scrolloff=5                " When scrolling, keep the cursor
                               " 5 lines below the top and 5 lines
                               " above the bottom of the screen

set shortmess=aAItW            " Avoid all the hit-enter prompts
set showcmd                    " Show the command being typed
set showmode                   " Show current mode
set spelllang=en_us            " Set the spellchecking language

set smartcase                  " Override `ignorecase` option
                               " if the search pattern contains
                               " uppercase characters

set synmaxcol=2500             " Limit syntax highlighting (this
                               " avoids the very slow redrawing
                               " when files contain long lines)

set tabstop=4                  " ┐
set softtabstop=4              " │ Set global <TAB> settings
set shiftwidth=4               " │ http://vimcasts.org/e/2
set expandtab                  " ┘

set ttyfast                    " Enable fast terminal connection
set undodir=~/.vim/undos       " Set directory for undo files
set undofile                   " Automatically save undo history
set virtualedit=all            " Allow cursor to be anywhere

set visualbell                 " ┐
set noerrorbells               " │ Disable beeping and window flashing
set t_vb=                      " ┘

set wildmode=longest,list,full
set wildmenu                   " Enable enhanced command-line
                               " completion (by hitting <TAB> in
                               " command mode, Vim will show the
                               " possible matches just above the
                               " command line with the first
                               " match highlighted)

set winminheight=0             " Allow windows to be squashed

" Fixes plugins that require a version of Python not loaded dynamically
" https://stackoverflow.com/a/41733943
if has('python') " if dynamic py|py3, this line already activates python2.
	let s:python_version = 2
elseif has('python3')
	let s:python_version = 3
else
	let s:python_version = 0
endif
" }}}
" General Key Mappings {{{
" Use a different mapleader (default is '\')
let mapleader = ','

" Remap VIM 0 to first non-blank character
map 0 ^

" Search and replace the word under the cursor
nmap <leader>* :%s/<C-r><C-w>//<Left>

" Makes gj/gk move by virtual lines when used without a count, and by
" physical lines when used with a count. This is perfect in tandem with
" relative numbers.
" http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Make the opening of the `.vimrc` file easier
nmap <leader>v :vsp $MYVIMRC<CR>

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Sudo write
cmap w!! w !sudo tee %<CR>

" Clear current search highlight
nmap <silent> // :nohlsearch<CR>

" Make Y behave like other capitals
nnoremap Y y$

" qq to record, Q to replay
nnoremap Q @q
" }}}
" Backups {{{
set nobackup
set nowb
set noswapfile
" }}}
" Buffers {{{
nnoremap <Tab> :bn<cr>
nnoremap <S-Tab> :bp<cr>
nmap ; :Buffers<cr>
map <leader>bd :BD<cr>
map <leader>bo :BufOnly<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\   exe "normal! g`\"" |
			\ endif

" Remember info about open buffers on close
set viminfo^=%
" }}}
" Clipboard {{{
set clipboard=unnamed          " ┐
" │ Use the system clipboard
if has('unnamedplus')          " │ as the default register
	set clipboard+=unnamedplus   " │
endif                          " ┘
" }}}
" Editing {{{
" Automatically strip the trailing whitespaces when files are saved
function! StripTrailingWhitespaces()
	" Save last search and cursor position
	let searchHistory = @/
	let cursorLine = line('.')
	let cursorColumn = col('.')

	" Strip trailing whitespaces
	%s/\s\+$//e

	" Restore previous search history and cursor position
	let @/ = searchHistory
	call cursor(cursorLine, cursorColumn)
endfunction
if has('autocmd')
	" Autocommand Groups
	" http://learnvimscriptthehardway.stevelosh.com/chapters/14.html

	" Use relative line numbers
	" http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/
	augroup relative_line_numbers
		autocmd!
		" Automatically switch to absolute line numbers when vim is in insert mode
		autocmd InsertEnter * :set norelativenumber
		" Automatically switch to relative line numbers when vim is in normal mode
		autocmd InsertLeave * :set relativenumber
	augroup END

	" Only strip the trailing whitespaces if the file type is
	" not in the excluded file types list
	augroup strip_trailing_whitespaces
		let excludedFileTypes = [
					\ 'markdown',
					\ 'mkd.markdown'
					\]

		autocmd!
		autocmd BufWritePre * if index(excludedFileTypes, &ft) < 0 | :call StripTrailingWhitespaces()
	augroup END

	" Turn on spell check for certain files
	augroup turn_on_spell_check
		autocmd!
		autocmd BufRead,BufNewFile *.md setlocal spell
	augroup END
endif

" http://vimcasts.org/episodes/soft-wrapping-text/
command! -nargs=* Wrap set wrap linebreak nolist
" }}}
" File Management {{{
" Let's use ripgrep as the grep program!
set grepprg=rg\ --vimgrep

" :W and :Save will escape a file name and write it
function! W(bang, filename)
	:exe "w".a:bang." ". fnameescape(a:filename)
endfunction
function! Save(bang, filename)
	:exe "save".a:bang." ". fnameescape(a:filename)
endfunction
command! -bang -nargs=* W :call W(<q-bang>, <q-args>)
command! -bang -nargs=* Save :call Save(<q-bang>, <q-args>)
" }}}
" Folding {{{
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
nnoremap <space><space> za
" }}}
" pbcopy/pbpaste {{{
" https://gist.github.com/burke/5960455
function! PropagatePasteBufferToOSX()
	let @n=getreg("")
	call system('pbcopy-remote', @n)
	echo "done"
endfunction
command! PropagatePasteBufferToOSX :call PropagatePasteBufferToOSX()
" }}}
" Plugins {{{
" Use vim-plug to manage plugins
" https://github.com/junegunn/vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
	execute '!curl -fLo ~/.vim/autoload/plug.vim
				\ https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/bundle')
Plug 'Chiel92/vim-autoformat'
Plug 'Konfekt/FastFold'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'albfan/nerdtree-git-plugin'
Plug 'alfredodeza/coveragepy.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'benmills/vimux'
Plug 'breuckelen/vim-resize'
Plug 'chrisbra/unicode.vim'
Plug 'christoomey/vim-sort-motion'
Plug 'christoomey/vim-tmux-navigator'
Plug 'easymotion/vim-easymotion'
Plug 'ervandew/supertab'
Plug 'gummesson/stereokai.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'idanarye/vim-merginal'
Plug 'jreybert/vimagit'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'kshenoy/vim-signature'
Plug 'ludovicchabant/vim-gutentags'
Plug 'mhinz/vim-grepper', { 'on': 'Grepper' }
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-ultisnips'
Plug 'qpkorr/vim-bufkill'
Plug 'raimondi/delimitmate'
Plug 'rhysd/clever-f.vim'
Plug 'roxma/nvim-yarp'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/gundo.vim'
Plug 'stevearc/vim-arduino'
Plug 'tomasr/molokai'
Plug 'tommcdo/vim-lion'
Plug 'tpope/tpope-vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/BufOnly.vim'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'w0rp/ale'
Plug 'wellle/targets.vim'
call plug#end()
filetype on
" }}}
" Plugin: Ale {{{
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0

nmap <silent> <C-p> :ALEPrevious<cr>
nmap <silent> <C-n> :ALENext<cr>
" }}}
" Plugin: clever-f.vim {{{
let g:clever_f_across_no_line = 1
let g:clever_f_timeout_ms = 3000
" }}}
" Plugin: Color Scheme {{{
set t_Co=256                   " Enable full-color support
set background=dark            " Use colors that look good
" on a dark background
colorscheme solarized          " Use custom color scheme
"}}}
" Plugin: coverage.py {{{
map <leader>cp :Coveragepy session<CR>
"}}}
" Plugin: EasyMotion {{{
" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

function! s:incsearch_config(...) abort
	return incsearch#util#deepextend(deepcopy({
				\   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
				\   'keymap': {
				\     "\<C-l>": '<Over>(easymotion)'
				\   },
				\   'is_expr': 0
				\ }), get(a:, 1, {}))
endfunction

function! s:config_easyfuzzymotion(...) abort
	return extend(copy({
				\   'converters': [incsearch#config#fuzzyword#converter()],
				\   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
				\   'keymap': {"\<C-l>": '<Over>(easymotion)'},
				\   'is_expr': 0,
				\   'is_stay': 1
				\ }), get(a:, 1, {}))
endfunction
noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
noremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())
" }}}
" Plugin: FZF {{{
let g:fzf_action = {
			\ 'ctrl-s': 'split',
			\ 'ctrl-v': 'vsplit'
			\ }
let g:fzf_session_path = $HOME . '/.vim/sessions'

" [,t ] Toggle fzf find
map <leader>t :Files<CR>

command! -bang -nargs=* Rg
			\ call fzf#vim#grep(
			\   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
			\   <bang>0 ? fzf#vim#with_preview('up:60%')
			\           : fzf#vim#with_preview('right:50%:hidden', '?'),
			\   <bang>0)
" map <leader>a :Ag<space>
map <leader>a :Rg<space>
" }}}
" Plugin: Grepper {{{
" Nice way to get a quickfix/location list to edit multiple files at once
map <leader>gr :Grepper -tool rg -query<space>
" }}}
" Plugin: Gundo {{{
" toggle gundo
" https://dougblack.io/words/a-good-vimrc.html
nnoremap <leader>u :GundoToggle<CR>
"}}}
" Plugin: indentLine {{{
let g:indentLine_faster = 1
let g:indentLine_color_term = 239
" }}}
" Plugin: LanguageClient-neovim {{{
set hidden

let g:LanguageClient_serverCommands = {
    \ 'python': ['python -m pyls'],
    \ }
" }}}
" Plugin: lion-vim {{{
let g:lion_squeeze_spaces = 1
" }}}
" Plugin: Markdown {{{
let g:vim_markdown_conceal = 0
let g:vim_markdown_folding_disabled=1
" }}}
" Plugin: molokai {{{
let g:rehash256 = 1
" }}}
" Plugin: ncm2 {{{
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect
" }}}
" Plugin: NERDTree {{{
let g:NERDTreeMapActivateNode = "<F3>"
let g:NERDTreeMapPreview      = "<F4>"

nnoremap <silent> <C-\> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" }}}
" Plugin: Supertab {{{
let g:SuperTabDefaultCompletionType = 'context'
" }}}
" Plugin: UltiSnips {{{
" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
" }}}
" Plugin: vim-autoformat {{{
let g:formatters_python = ['yapf']
let g:formatter_yapf_style = 'google'
" }}}
" Plugin: vim-fugitive {{{
nnoremap <leader>gP :Gpull \| :Gpush<cr>
nnoremap <Leader>gb :Gblame<CR>
" }}}
" Plugin: vim-gitgutter {{{
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_modified_removed = '<'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'

let g:gitgutter_override_sign_column_highlight = 1
highlight SignColumn guibg=bg
highlight SignColumn ctermbg=bg

nmap <Leader>ga <Plug>GitGutterStageHunk
nmap <Leader>gn <Plug>GitGutterNextHunk
nmap <Leader>gp <Plug>GitGutterPrevHunk
nmap <Leader>gu <Plug>GitGutterUndoHunk
" }}}
" Plugin: vim-grepper {{{
let g:grepper = {}
runtime autoload/grepper.vim
let g:grepper.jump = 1
let g:grepper.stop = 500
" }}}
" Plugin: vim-merginal {{{
nmap <Leader>gb :Merginal<CR>
" }}}
" Plugin: vimagit {{{
let g:magit_discard_untracked_do_delete=1

nnoremap <leader>gs :Magit<CR>
" }}}
" Plugin: Vimux {{{
map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vi :VimuxInspectRunner<CR>
map <Leader>vl :VimuxRunLastCommand<CR>
map <Leader>vz :VimuxZoomRunner<CR>
" }}}
" Plugin: Vim Tmux Navigator {{{
" By default, Vim Tmux Navigator binds <C-\> to go to the previous pane.
" I never really use this and would like to use that keymap for
" something else, so rather than binding-then-unbinding it, this
" disables the plugin's keymaps altogether; I redefined the others
" here.
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
" }}}
" Status Line {{{
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

function! GetGitBranchName()
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
" }}}
