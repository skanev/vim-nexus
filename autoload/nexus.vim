let g:nexus_runinfo = {}

function! nexus#reset()
  let g:nexus_runinfo.passed = 0
  let g:nexus_runinfo.failed = 0
  let g:nexus_runinfo.total = 0
endfunction

call nexus#reset()

" Test Runner callbacks {{{1
function! nexus#started(total)
  let g:nexus_runinfo.passed = 0
  let g:nexus_runinfo.failed = 0
  let g:nexus_runinfo.total = a:total
endfunction

function! nexus#passed()
  let g:nexus_runinfo.passed += 1
  call nexus#updateStatus()
endfunction

function! nexus#failed()
  let g:nexus_runinfo.failed += 1
  call nexus#updateStatus()
endfunction

function! nexus#finished()
endfunction

" Powerline callbacks {{{1
function! nexus#status()
  let indicators = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█']

  let total = g:nexus_runinfo.total
  let passed = g:nexus_runinfo.passed
  let failed = g:nexus_runinfo.failed
  let ran = passed + failed

  if total == 0 || ran == 0
    return ' '
  elseif ran >= total
    if failed == 0
      return '✔'
    else
      return '✘'
    endif
  else
    let progress = float2nr(((ran * 1.0) / total) * (len(indicators) - 1))
    return indicators[progress]
  endif
endfunction

" Utility {{{1
function! nexus#updateStatus()
  call Pl#UpdateStatusline(1)
endfunction
