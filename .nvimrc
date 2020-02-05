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


" {{{ pmenu hax cause desertcocks
" holy shit, why the fuck is the auto completion menu is fucked
autocmd ColorScheme * highlight Pmenu ctermbg=60 ctermfg=81
autocmd ColorScheme * highlight PmenuSel ctermbg=60 ctermfg=50
autocmd ColorScheme * highlight Search ctermbg=24 ctermfg=49
" goodbye desert256 hello desertrocks
colorscheme desert256v2
"let g:desertrocks_show_whitespace=1
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
let g:ale_sign_error = '🐒'
let g:ale_sign_warning = '🥔'
let g:ale_fixers = {
\   'sh': ['shfmt'],
\   'python': ['black'],
\}
let g:ale_sh_shfmt_options = '-i 2'
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

" {{{ \X key maps
" note: don't use <Leader> but it looks like a headache to use correctly,
"       so just use \ directly.
"
" good read about this: https://www.reddit.com/r/vim/wiki/the_leader_mechanism

" turn off fucking ex mode 
map Q <Nop>
map gQ <Nop>

map \a :ALEToggle<CR>
map \f :ALEFix<CR>
map \i :GoImports<CR>
map \c :close<CR>

" close all windows except active - won't autowrite as long as you don't fuck
" with hidden and autowrite, always use the vim-sensible
map \o :only<CR>

" mildly useful - i usually like the wrap because i can navigate the wrap with
" gj and gk
map \w :set wrap!<CR>

" handy to visually see whitespace; easier than figuring out how to highlight
" and toggle whitespace highlighting
map \s :set list!<CR>

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
" }}}

" {{{ vim-go settings
" for some reason ale doesn't pick up golangci-lint
let g:go_metalinter_command='golangci-lint'
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
"  }}}
