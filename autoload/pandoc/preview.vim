" load function definitions only once per session
if exists('s:pandoc_preview_loaded')
    finish
else
    let s:pandoc_preview_loaded = 1
endif

fu! s:OnEvent(job_id, data, event) dict
  if a:event == 'stderr'
    if join(a:data)
      let str = self.shell.' stderr: '.join(a:data)
      echoerr str
    endif
  elseif a:event == 'exit' && self.shell == 'pandoc'
    let b:pandoc_running = 0
  endif
endfu

let s:callbacks = {
    \ 'on_stderr': function('s:OnEvent'),
    \ 'on_exit': function('s:OnEvent')
\ }

fu! s:bufferChanged()
    if !exists('b:changedtickLast') || b:changedtickLast != b:changedtick
        let b:changedtickLast = b:changedtick
        return 1
    endif

    return 0
endfu

fu! s:generateHtml(outputPath, markdownText)
    let args = [
            \ 'pandoc',
            \ '--standalone',
            \ '--toc',
            \ '--from='.g:pandoc_preview_format,
            \ '-o', a:outputPath
        \ ]

    if exists('b:pandoc_preview_template')
        call add(args, '--template='.b:pandoc_preview_template)
    endif

    if exists('b:pandoc_preview_css')
        call add(args, '--css')
        call add(args, b:pandoc_preview_css)
    endif

    let job_id = jobstart(args,
        \ extend({'shell': 'pandoc'}, s:callbacks))

    if job_id == 0
        echo 'wrong arguments'
    elseif job_id == -1
        echo 'cannot run shell'
    endif

    call chansend(job_id, a:markdownText)
    call chanclose(job_id, 'stdin')
endfu


function! s:getBufferLines(bufnr)
  let lines = getbufline(a:bufnr, 1, "$")

  return lines
endfu

fu! s:outputPath()
    return fnamemodify(bufname(), ':r') . '.html'
endfu

fu! s:pandocRender()
    " Only update if pandoc is not running and if buffer has changed
    if exists('b:pandoc_running') && b:pandoc_running || !s:bufferChanged()
        return
    endif

    let b:pandoc_running = 1
    let bufnr = expand('<bufnr>')
    let markdownText = join(s:getBufferLines(bufnr), "\n")
    call s:generateHtml(s:outputPath(), markdownText)
endfu

fu! s:startLiveServer(htmlPath)
    " mount=/:. to make relative paths accessible
    let b:pandoc_preview_live_server_id = jobstart([
            \ 'live-server',
            \ '--port='.string(g:pandoc_preview_port),
            \ '--mount='.$HOME.':'.$HOME,
            \ '--open='.a:htmlPath
        \],
        \ extend({'shell': 'live-server'}, s:callbacks))
endfu

fu! pandoc#preview#StopPreview()
    if b:pandoc_preview_live_server_id != 0
        call jobstop(b:pandoc_preview_live_server_id)
        let b:pandoc_preview_live_server_id = 0
    else
        echo 'No active pandoc preview'
    endif

    " Stop group trigger
    autocmd! pandoc-preview * <buffer>
endfu

fu! pandoc#preview#StartPreview()
    " don't start preview if already active
    if b:pandoc_preview_live_server_id != 0
        echo 'Preview already active'
        return
    endif

    augroup pandoc-preview
        " turn off previous autocmd of this group
        autocmd!

        autocmd CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:pandocRender()
        autocmd BufUnload <buffer> call pandoc-preview#StopPreview()
    augroup END

    call s:pandocRender()
    call s:startLiveServer(s:outputPath())
endfu
