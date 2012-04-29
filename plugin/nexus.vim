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
let s:modes.rspec.file = '"command rspec --format nested " . expand("%") . " --drb"'
let s:modes.rspec.line = '"command rspec --format nested " . expand("%") . " --line " . line(".") . " --drb"'

" Nexus utility functions {{{1
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

  if has_key(commands, a:target)
    let command = eval(commands[a:target])
    let g:nexus_last_command = command
    call s:tmux(command)
  elseif exists("g:nexus_last_command")
    call s:tmux(g:nexus_last_command)
  else
    echohl ErrorMsg | echo "Nexus: undefined command " . a:target | echohl None
    return
  end
endfunction

function! s:sendKeys(text)
  if !s:sessionRunning()
    echohl ErrorMsg | echo "Cannot send to tmux - session not running" | echohl None
    return
  endif

  let session = s:currentSessionName()
  let lines = split(a:text, "\n")

  for line in lines
    let keys = shellescape(line)
    let keys = substitute(keys, ';', "' '" . '\\;' . "' '", "g")
    call system("tmux send-keys -t " . session . " " . keys . " C-m")
  endfor
endfunction

function! s:sessionRunning()
  let existingSessions = split(system("tmux list-sessions | cut -f 1 -d :"))
  return index(existingSessions, s:currentSessionName()) >= 0
endfunction

" Session management {{{1
function! s:createSession()
  let session = s:currentSessionName()
  let existingSessions = split(system("tmux list-sessions | cut -f 1 -d :"))

  if s:sessionRunning()
    echohl WarningMsg | echo "tmux session already created. Run 'tmux attach -t " . session . "' to join it." | echohl None
    return
  end

  call system("tmux new-session -d -s " . session)
  call system("tmux rename-window -t " . session . " nexus")
  echohl MoreMsg | echo "tmux session created. Run 'tmux attach -t " . session . "' to join it." | echohl None
endfunction

" Sending text {{{1
function! s:sendSelection()
  call s:sendKeys(s:selectedText())
endfunction

function! s:sendBuffer()
  call s:sendKeys(s:currentBufferContents())
endfunction

" Reading text {{{1
function! s:readPane()
  if !s:sessionRunning()
    echohl ErrorMsg | echo "Cannot send to tmux - session not running" | echohl None
    return
  endif

  let session = s:currentSessionName()
  call system('tmux capture-pane -t ' . session)

  let contents = system('tmux save-buffer - | cat')
  let contents = substitute(contents, '\v[\n ]+$', '', 'g')
  let lines = split(contents, "\n")

  call append(line('.'), lines)
endfunction

" Utility functions {{{1
function! s:selectedText()
  try
    let a_save = @a
    normal! gv"ay
    return @a
  finally
    let @a = a_save
  endtry
endfunction

function! s:currentBufferContents()
  return join(getbufline('%', 0, '$'), "\n")
endfunction

" Commands {{{1
command! Nexus :call <SID>createSession()
command! -range NexusSendSelection :call <SID>sendSelection()
command! NexusSendBuffer :call <SID>sendBuffer()
command! NexusReadPane :call <SID>readPane()

" Mappings {{{1
noremap <expr> <Plug>NexusRunFile <SID>run('file')
noremap <expr> <Plug>NexusRunLine <SID>run('line')
noremap <expr> <Plug>NexusSendBuffer <SID>sendBuffer()
vnoremap <silent> <Plug>NexusSendSelection :NexusSendSelection<CR>gv

" vim:set ft=vim foldmethod=marker ts=2 sts=2 sw=2 et
