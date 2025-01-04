# config
A set of utilities and configurations that make my life easier 

## ocr.sh[^1]
Small shell script that extracts text from images using "Llama 3.2". Requires [ollama](https://ollama.com/) and [llama3.2-vision](https://ollama.com/library/llama3.2-vision)

## stt.sh[^1] 
Transcribe video or audio. Requires [whisper-standalone-win](https://github.com/Purfview/whisper-standalone-win)

## `.tmux.conf`
[Tmux](https://github.com/tmux/tmux/wiki) colour configuration for showing colour palettes accurately when using Neovim in a tmux session. You can safe it under `$HOME` 

## `.zshrc`
Zsh configuration. Requires [Oh My Zsh](https://ohmyz.sh/). It contains configuration for [asdf version manager](https://github.com/asdf-vm/asdf), [Julia](https://github.com/asdf-vm/asdf), [uv](https://docs.astral.sh/uv/) and [Clojure](https://clojure.org/). It should be saved under `$HOME`

## kitty.conf 
[kitty](https://sw.kovidgoyal.net/kitty/) terminal. Requires [Fira Code](https://github.com/tonsky/FiraCode). It can be saved under `$HOME/.config/kitty/` or `$HOME`

## Modelfile
Olama model file for creating a coder model based on quantised "Qwen 2.5 coder" [qwen2.5-coder:14b-instruct-q4_K_M](https://ollama.com/library/qwen2.5-coder:14b-instruct-q4_K_M)


---
[^1]: Note that shell scripts could be converted to shell functions that can live under `.zshrc` 
