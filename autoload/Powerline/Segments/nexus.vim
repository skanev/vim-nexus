if !has_key(g:Powerline#Colorschemes#default#colorscheme, 'nexus:status')
  let g:Powerline#Colorschemes#default#colorscheme['nexus:status'] = Pl#Hi#Segments(['nexus:status'], {
		\ 'n': ['gray10', 'gray6'],
		\ 'N': ['gray4', 'gray1'],
		\ 'i': ['mediumcyan', 'darkblue'],
  \ })[1]
  let g:Powerline#Colorschemes#default#colorscheme['nexus:status.success'] = Pl#Hi#Segments(['nexus:status.success'], {
		\ 'n': ['darkgreen', 'gray6'],
		\ 'N': ['gray4', 'gray1'],
		\ 'i': ['mediumgreen', 'darkblue'],
  \ })[1]
  let g:Powerline#Colorschemes#default#colorscheme['nexus:status.failure'] = Pl#Hi#Segments(['nexus:status.failure'], {
		\ 'n': ['darkred', 'gray6'],
		\ 'N': ['gray4', 'gray1'],
		\ 'i': ['mediumred', 'darkblue'],
  \ })[1]
endif

let g:Powerline#Segments#nexus#segments = Pl#Segment#Init(['nexus',
    \ Pl#Segment#Create('status',
      \ Pl#Segment#Create('success', '%{nexus#segmentSuccess()}'),
      \ Pl#Segment#Create('failure', '%{nexus#segmentFailure()}'),
    \ )
  \ ])
