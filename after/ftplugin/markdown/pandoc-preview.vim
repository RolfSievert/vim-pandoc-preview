
" load definitions only once per buffer
if exists('b:pandoc_preview_loaded')
    finish
else
    let b:pandoc_preview_loaded = 1
endif

""" Set global plugin variables

if !exists('g:pandoc_preview_port')
    let g:pandoc_preview_port = 9009
endif

if !exists('g:pandoc_preview_format')
    let g:pandoc_preview_format = 'gfm'
endif

let s:plugindir = expand('<sfile>:p:h:h:h:h')

" check if template is set
if !exists('g:pandoc_preview_template')
    let b:pandoc_preview_template = s:plugindir.'/data/templates/bootstrap.html'
elseif (g:pandoc_preview_template == 'bootstrap')
    let b:pandoc_preview_template = s:plugindir.'/data/templates/bootstrap.html'
else
    let b:pandoc_preview_template = g:pandoc_preview_template
endif

" check if css is set
if exists('g:pandoc_preview_css')
    let b:pandoc_preview_css = g:pandoc_preview_css
endif


""" Set buffer local variables

let b:pandoc_preview_live_server_id = 0

""" Define user commands

command! -nargs=0 -buffer PandocPreview call pandoc#preview#StartPreview()
command! -nargs=0 -buffer PPreview PandocPreview
command! -nargs=0 -buffer PandocPreviewStop call pandoc#preview#StopPreview()
command! -nargs=0 -buffer PPreviewStop PandocPreviewStop
