if !has_key(g:Powerline#Colorschemes#default#colorscheme, 'nexus:status')
  let g:Powerline#Colorschemes#default#colorscheme['nexus:status'] = Pl#Hi#Segments(['nexus:status'], {
		\ 'n': ['gray10', 'gray6'],
		\ 'N': ['gray4', 'gray1'],
		\ 'i': ['mediumcyan', 'darkblue'],
  \ })[1]
endif

let g:Powerline#Segments#nexus#segments = Pl#Segment#Init(['nexus',
	\ Pl#Segment#Create('status', '%{nexus#status()}')
\ ])
