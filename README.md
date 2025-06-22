# config

A set of utilities and configurations that make my life easier

## ocr.sh[^1]

Small shell script that extracts text from images using "llama 3.2". Requires [ollama](https://ollama.com/) and [llama3.2-vision](https://ollama.com/library/llama3.2-vision)

## stt.sh[^1]

Transcribe video or audio. Requires [whisper-standalone-win](https://github.com/Purfview/whisper-standalone-win)

## tts.sh

Convert text to speech using voice models. Requires [Piper TTS](https://github.com/rhasspy/piper) and optionally [ffmpeg](https://ffmpeg.org/) for MP3 conversion.

## todo.sh

Create a simple to-do list. `.zshrc` already contains a simple function ([thanks to Chris Albon](https://bsky.app/profile/chrisalbon.com/post/3ld24aoq4ik2p)) that does a simpler form of what `todo.sh` can do. It's always a good idea to [keep a work log](https://www.youtube.com/watch?v=HiF83i1OLOM).

## cmdollama.sh

Generate Unix commands using [ollama](https://ollama.com/) with [granite3.1-dense:8b](https://www.ollama.com/library/granite3.1-dense). Inspired by [llmpeg](https://github.com/jjcm/llmpeg)

## `.tmux.conf`

[tmux](https://github.com/tmux/tmux/wiki) colour configuration for showing colour palettes accurately when using Neovim in a tmux session. You can safe it under `$HOME`

## `.zshrc`

[Zsh](https://www.zsh.org/) configuration. Requires [Oh My Zsh](https://ohmyz.sh/) and (optionally) [Glow](https://github.com/charmbracelet/glow). It contains configurations for the [asdf](https://github.com/asdf-vm/asdf) version manager, [Julia](https://julialang.org/), the [uv](https://docs.astral.sh/uv/) package and project manager, [Clojure](https://clojure.org/) and [Go](https://go.dev/). It should be saved under `$HOME`

## `kitty.conf`

[kitty](https://sw.kovidgoyal.net/kitty/) terminal. Requires [Fira Code](https://github.com/tonsky/FiraCode). It can be saved under `$HOME/.config/kitty/` or `$HOME`

## Modelfile

[ollama](https://ollama.com/) model file for creating a coder model based on quantised "Qwen 2.5 coder" [qwen2.5-coder:14b-instruct-q4_K_M](https://ollama.com/library/qwen2.5-coder:14b-instruct-q4_K_M)

## settings.json

My settings for [Zed](https://zed.dev/) editor

---

[^1]: Note that small shell scripts could be converted to shell functions that can live under `.zshrc`
