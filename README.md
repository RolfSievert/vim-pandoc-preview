
# vim-pandoc-preview

Live preview markdown files in the browser while editing (using `pandoc` and `live-server`).
This plugin makes it possible for you to use your custom `pandoc` style sheets and templates.

# TODO

- Override style sheet and template if either is present in the working directory
- Add command to generate html file instead of always generating it when previewing

# Requirements

Follow links for installation instructions:

- [pandoc](https://github.com/jgm/pandoc)
- [live-server](https://github.com/tapio/live-server)

# Usage

## Commands

```vim
" Start preview
:PandocPreview
:PPreview

" Stop preview
:PandocPreviewStop
:PPreviewStop
```

## Configuration

```vim
" Specify a custom style sheet for html generation
let g:pandoc_preview_css = 'path/to/style_sheet.css'

" Specify a custom template for html generation
" or the following options (implicitly points to files in '.../vim-pandoc-preview/data/templates/'):
"   - 'bootstrap' (default)
let g:pandoc_preview_template = 'path/to/template.html'
```
