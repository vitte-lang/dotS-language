# Editor Setup

## Vim
- `editor/vim/ftdetect/dots.vim`
- `editor/vim/syntax/dots.vim`
- `editor/vim/indent/dots.vim`
- `editor/vim/plugin/dots.vim`

Install by linking these files into your Vim runtime path.

## Emacs
- `editor/emacs/dots-mode.el`

Load with:
```elisp
(load "/path/to/editor/emacs/dots-mode.el")
```

## Nano
- `editor/nano/dots.nanorc`

Add to `~/.nanorc`:
```ini
include /path/to/editor/nano/dots.nanorc
```

