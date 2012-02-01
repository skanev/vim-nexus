" nexus.vim - Get vim and tmux to play nice together
" Author: Stefan Kanev
" URL:    http://github.com/skanev/vim-nexus

" Modes and targets {{{1
let s:modes = {}

let s:modes.cucumber = {}
let s:modes.cucumber.matcher = '\.feature$'
let s:modes.cucumber.file = '"command cucumber " . expand("%") . " --drb"'
let s:modes.cucumber.line = '"command cucumber " . expand("%") . ":" . line(".") . " --drb"'

let s:modes.rspec = {}
let s:modes.rspec.matcher = '_spec\.rb$'
let s:modes.rspec.file = '"/Users/aquarius/.vim/bundle/vim-nexus/bin/nexus_rspec " . expand("%") . " --drb"'
let s:modes.rspec.line = '"/Users/aquarius/.vim/bundle/vim-nexus/bin/nexus_rspec " . expand("%") . " --line " . line(".") . " --drb"'

" Executing a target {{{1
function! s:currentSessionName()
  return fnamemodify(getcwd(), ':t')
endfunction

function! s:tmux(command)
  let session = s:currentSessionName()
  let escaped = shellescape(a:command)
  let tmuxCall = "tmux send-keys -t " . session . ":nexus C-l C-u " . escaped . " C-m"
  call system(tmuxCall)
endfunction

function! s:run(target)
  let commands = {}

  for [mode, definition] in items(s:modes)
    if match(expand("%"), definition.matcher) != -1
      let commands = definition
      break
    endif
  endfor

  if !has_key(commands, a:target)
    echohl ErrorMsg | echo "Nexus: undefined command " . a:target | echohl None
    return
  end

  call s:tmux(eval(commands[a:target]))
endfunction

" Creating a session {{{1
function! s:createSession()
  let session = s:currentSessionName()
  let existingSessions = split(system("tmux list-sessions | cut -f 1 -d :"))

  if index(existingSessions, session) >= 0
    echohl WarningMsg | echo "tmux session already created. Run 'tmux attach -t " . session . "' to join it." | echohl None
    return
  end

  call system("tmux new-session -d -s " . session)
  call system("tmux rename-window -t " . session . " nexus")
  echohl MoreMsg | echo "tmux session created. Run 'tmux attach -t " . session . "' to join it." | echohl None
endfunction

function! NexusLoadQuickfix(file)
  let oldformat = &errorformat
  set errorformat=%f:%l:%m
  exec "cgetfile ".a:file
  let &errorformat = oldformat
endfunction

command! Nexus :call <SID>createSession()

" Mappings {{{1
map <expr> <Plug>NexusRunFile <SID>run('file')
map <expr> <Plug>NexusRunLine <SID>run('line')

" vim:set ft=vim foldmethod=marker ts=2 sts=2 sw=2
