" make sure to:
"   mkdir -p ~/.config/nvim && echo 'source ~/.nvimrc' >> ~/.config/nvim/init.vim
" also install vim-plug:
"  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" Then call :PlugInstall

call plug#begin()
Plug 'davidhalter/jedi-vim'
Plug 'nnathan/desertrocks'
Plug 'fatih/vim-go', { 'tag': '*' }
" we really need to get rid of this - github.com/nnathan/desertrocks
Plug 'flazz/vim-colorschemes'
" this only installs fzf - doesn't load the damn plugin
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-sensible'
Plug 'udalov/kotlin-vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'w0rp/ale'
Plug 'simnalamburt/vim-mundo'
call plug#end()

" {{{ set mapleader to "," - i don't use the comma in normal mode anyway
" good read about this written by romainl:
" https://www.reddit.com/r/vim/wiki/the_leader_mechanism
" basically any plugin can steal and override your leader maps, so it's
" better not to rely on leader for local maps, and use two separate
" namespaces; I use backslash for my local ones, and I use comma for any
" plugin provided maps like jedi.
let mapleader = ","
" }}}

" {{{ \X key maps
" note: don't use <Leader> but it looks like a headache to use correctly,
"       so just use \ directly.
"
" good read about this: https://www.reddit.com/r/vim/wiki/the_leader_mechanism

" provide an alternative way to call "," (backwards repeat of 'f', 'T', 't', 'F')
" not sure if needed; leader sets , but it doesn't seem to be slow to register
" a single comma vs. map.
"map \; ,


" turn off fucking ex mode
map Q <Nop>
map gQ <Nop>

map \a :ALEToggle<CR>
map \f :ALEFix<CR>
map \i :GoImports<CR>
map \c :close<CR>

" handy on mac - open filename of current buffer using "open" program
map \O :!open %<CR>

" close all windows except active - won't autowrite as long as you don't fuck
" with hidden and autowrite, always use the vim-sensible
map \o :only<CR>

" mildly useful - i usually like the wrap because i can navigate the wrap with
" gj and gk - but handy for quick visual check to see if a line is wrapped
map \w :set wrap!<CR>

" would rather split into tabs than use the set list! feature
" which is better served with good syntax highlighting for trailing
" space
map \s :tab split<CR>

" useful to rearrange tabs
" i wanted to use \n and \p for next and prev
" but i went with (p)rev and undo (P)rev
" so i can keep \n for numbers
map \p :tabmove -1<CR>
map \P :tabmove +1<CR>

" handy to visually see whitespace; easier than figuring out how to highlight
" and toggle whitespace highlighting
"map \s :set list!<CR>

" ruler is usually on, but i guess in vim doesn't do it on
map \r :set ruler!<CR>

" fast quit - way quicker than :q
map \q :q<CR>

" okay this is heaps useful - it opens a new tab with the directory browser
" in the same directory as where the buffer was opened
" courtesy of /u/-romainl- (and same nick on freenode vim)
map \. :tabedit %:p:h<CR>

" convenient to open a new tab instead of :tabnew
map \t :tabnew<CR>

" toggle mundo
map \m :MundoToggle<CR>

" toggle line numbers
map \n :set nu!<CR>

"augroup netrw_mapping
"  autocmd!
"  autocmd filetype netrw nnoremap \f :FZF %:p:h<CR>
"augroup END

" }}}

" {{{ pmenu hax cause desertcocks
" holy shit, why the fuck is the auto completion menu is fucked
autocmd ColorScheme * highlight Pmenu ctermbg=60 ctermfg=81
autocmd ColorScheme * highlight PmenuSel ctermbg=60 ctermfg=50
autocmd ColorScheme * highlight Search ctermbg=24 ctermfg=49
" goodbye desert256 hello desertrocks
let g:desertrocks_show_whitespace=1
colorscheme desertrocks

" }}}

" {{{ other useful remaps
" opens tag on current cursor in a new tab when you press space-^]
" similar to ctrl-W ctrl-] (which opens in a new window)
nnoremap <space><C-]> :tab tag <C-r><C-w><CR>

" unhighlight search
nnoremap <esc> :noh<return><esc>
" }}}

" {{{ ale display & fixers

" this is black flake8 setup
"[flake8]
"max-line-length = 80
"...
"select = C,E,F,W,B,B950
"ignore = E203, E501, W503

let g:ale_sign_error = '🐒'
let g:ale_sign_warning = '🥔'

" remember to run:
" go install honnef.co/go/tools/cmd/staticcheck
" go install github.com/mgechev/revive
let g:ale_linters = {
\   'go': ['revive', 'staticcheck'],
\   'c': ['gcc', 'clang']
\}
let g:ale_go_golangci_lint_options = '--enable gofmt'
let g:ale_go_golangci_lint_package = 1
let g:ale_go_staticcheck_lint_package = 1

let g:ale_fixers = {
\   'sh': ['shfmt'],
\   'python': ['black', 'isort'],
\   'go': ['goimports', 'gofmt'],
\}
let g:ale_go_gofmt_options = '-s'
let g:ale_sh_shfmt_options = '-i 2'
" }}}

" {{{ jedi settings
let g:jedi#popup_on_dot = 0
" }}}

" {{{ unsure why i have this - need to revisit these settings
" apparently this is deprecated now?
set completeopt-=preview
" }}}

" {{{ misc options - list and undo settings
set listchars=tab:▒░,trail:▓
set foldmethod=marker

" looks useful - recommended by the Mundo plugin
set undofile
set undodir=~/.local/share/nvim/undo
" }}}

" {{{ gutentags
" enable gtags module
let g:gutentags_modules = ['ctags', 'gtags_cscope']

" config project root markers.
let g:gutentags_project_root = ['.root']

" generate datebases in my cache directory, prevent gtags files polluting my project
let g:gutentags_cache_dir = expand('~/.cache/tags')

" change focus to quickfix window after search (optional).
let g:gutentags_plus_switch = 1

" exclude annoying directories/files
let g:gutentags_ctags_exclude = ['node_modules', 'public', 'bin', 'build', 'CMakeFiles', 'cpplint.py']
" }}}

" {{{ vim-go settings
" for some reason ale doesn't pick up golangci-lint
let g:go_metalinter_command='golangci-lint run --enable gofmt'
"let g:go_metalinter_autosave = 1
" }}}

" {{{ just some thoughts
"
" todo:
" whitespace indicator at the end of lines - and a toggle for (no)list
" \s
" wrap
" \w
" https://gist.github.com/while0pass/511985
" fork desert + fix pmenu/psel + get rid of vim-colorschemes because it's fucking dead and wasteful.
" steal both highlight and search highlight from jellyx

" just some useful reminders
" :GoKeyify -> converts go struct to keyed fields
" :GoFillStruct -> fills all unnamed fields in struct with default value
"

" todo for fuckingdesert256
" we need pmenu from jellyx but with cactus (maybe light) green
" copy bracket highlighter from jellyx (    )
" autohiglight when in scope (if possible)
" import the yellow from v2 into v1
" import the green from v1 to v2
" so we need a better diff view that clearly explains what is going on.        
"  - green goes in
"  - redish goes out
"  - underline for in-line changes + colour the light slightly
"  - jellybeans is good inspiration       
"  - grayvim256
"  - improve the heredoc colouring for shell maybe?  
"  remind to put somethhing up like a gist - to explain how to fuck off all
"  the deoplete nonsense
"
"  remind to put somethhing up like a gist - to explains explain in
"
"  completely fucking disable EX mode - this should be in VIM FUCKING SENSIBLE.
"
"
"  reminder: write somtehing about ale and fixers because it's fucking
"  impossible to understand
"
"  reminder: crazy shit vimrc across the board - why the fuck are people using
"  the mouse
"
"  reminder: need to figure out VERY BASIC vimscript - let, set, echo, the bang
"
"  reminder: moving between the line wrap - write about it
"
"  reminder: figure out how to stop the continuation comments
"
"  reminder: see if i can :FZF from directory view - becauase (1) you can
"  start from narrow scope or (2) you want to widen scope of search
"
"  reminder: seek better way to do gk/gj on wrapped lines with little to no
"  remapping
"
"  reminder: <Ctrl-f> when editing command -  and q: q? etc.
"  }}}    

" maybe i want these because of hanging indent.
"autocmd FileType yaml setlocal noautoindent | setlocal paste
"autocmd FileType yaml setlocal nosmartindent | setlocal paste


autocmd FileType tex setlocal noautoindent | setlocal paste
autocmd FileType tex setlocal nosmartindent | setlocal paste
