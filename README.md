# config
A set of utilities and configurations that make my life easier 

## ocr.sh[^1]
Small shell script that extracts text from images using "Llama 3.2". Requires [ollama](https://ollama.com/) and [llama3.2-vision](https://ollama.com/library/llama3.2-vision)

## stt.sh[^1] 
Transcribe video or audio. Requires [whisper-standalone-win](https://github.com/Purfview/whisper-standalone-win)

## tts.sh  
Convert text to speech using voice models. Requires [Piper TTS](https://github.com/rhasspy/piper) and optionally [ffmpeg](https://ffmpeg.org/) for MP3 conversion.

## todo.sh
Create a simple to-do list. `.zshrc` already contains a simple function ([thanks to Chris Albon](https://bsky.app/profile/chrisalbon.com/post/3ld24aoq4ik2p)) that does a simpler form of what `todo.sh` can do. It's always a good idea to [keep a work log](https://www.youtube.com/watch?v=HiF83i1OLOM).

## ollmpeg.sh  
Generate `ffmpeg` commands using [ollama](https://ollama.com/) with [granite3.1-dense:8b](https://www.ollama.com/library/granite3.1-dense). Based on [llmpeg](https://github.com/jjcm/llmpeg)

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
