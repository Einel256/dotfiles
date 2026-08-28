# ─── Meta ───────────────────────────────────────────────────────
# インタラクティブシェル以外では読み込まない
[[ $- != *i* ]] && return

# ─── Environment & PATH (重複防止) ──────────────────────────────
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  /sbin
  /usr/sbin
  $path
)

export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export BAT_THEME="base16"
export SUDO_PROMPT="$(tput setaf 1 bold)Passsss!!:$(tput sgr0)"

# ─── History ─────────────────────────────────────────────────────
HISTSIZE=5000
SAVEHIST=5000
HISTFILE="${HOME}/.zsh_history"

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# ─── Zsh Options ─────────────────────────────────────────────────
setopt AUTO_MENU
setopt LIST_AMBIGUOUS
setopt NO_CASE_GLOB
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NULL_GLOB

# ─── Keybinds & Input Method ─────────────────────────────────────
bindkey -e

# fcitx5が起動していない場合のみバックグラウンドで起動（無限ループ回避）
if ! pgrep -x fcitx5 >/dev/null 2>&1; then
    fcitx5 >/dev/null 2>&1 &!
fi

# ─── Zinit Plugin Manager ────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# プラグイン読み込み（ここだけで一括管理）
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions 設定
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737994"

# ─── Completion Engine Setup ─────────────────────────────────────
autoload -Uz compinit
# 24時間に1回のみキャッシュを更新（高速化）
if [[ -n "${HOME}/.zcompdump(#qN.mh+24)" ]]; then
    compinit -d "${HOME}/.zcompdump"
else
    compinit -C
fi
zinit cdreplay -q

# Completion Styling
zstyle ':completion:*' matcher-list 'm:{A-Za-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-flags --height=17 --preview-window=right:50%:border:right

# ─── External Tools Initializations ──────────────────────────────
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ─── Aliases ─────────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --color=always'
    alias ll='eza --icons --color=always -l'
    alias la='eza --icons --color=always -a'
    alias lla='eza --icons --color=always -la'
    alias lt='eza --icons --color=always -a --tree --level=1'
fi

alias grep='grep --color=always'
alias bat='bat --paging=never'
alias lzg='lazygit'
alias lzd='lazydocker'
alias cbonsai='cbonsai -l -i -w 1'
alias clock='tty-clock -c -b -C 6'
alias show='kitty +kitten icat'
alias diff='kitty +kitten diff'
alias aqua='asciiquarium'
alias matrix='cmatrix -s'
alias ip='curl https://ipinfo.io'
alias load='source ~/.zshrc'
alias msolve='systemctl --user restart pipewire pipewire-pulse wireplumber'

# Media Conversion Aliases
alias wav='for f in *.*; do [[ "$f" == *.wav ]] && continue; [[ -f "$f" ]] && ffmpeg -i "$f" -map_metadata 0 -fflags +bitexact -ar 48000 -ac 2 -acodec pcm_s16le "${f%.*}.wav" 2>/dev/null && echo "done: ${f%.*}.wav"; done'
alias mp3='for f in *.*; do [[ "$f" == *.mp3 ]] && continue; [[ -f "$f" ]] && ffmpeg -i "$f" -map_metadata 0 -acodec libmp3lame -b:a 320k "${f%.*}.mp3" 2>/dev/null && echo "done: ${f%.*}.mp3"; done'
alias ytf='yt-dlp -x --audio-format flac --audio-quality 0 --embed-metadata --embed-thumbnail -o "%(title)s.%(ext)s"'
alias ytv='yt-dlp -f "bv*+ba/b" -S ext:mp4:m4a --merge-output-format mp4'

# ─── Functions ───────────────────────────────────────────────────

video() {
    mpv --force-window=yes "$@" &!
    # exit を削除（ターミナルが閉じないように）
}

gitmain() {
    git config --global user.name "HirokouMediaCreate"
    git config --global user.email "hirokoumediacreate@gmail.com"
    echo "Switched to work account:"
    echo "  user.name:  $(git config --global user.name)"
    echo "  user.email: $(git config --global user.email)"
}

gitsub() {
    git config --global user.name "Einel256"
    git config --global user.email "lexingyihu@gmail.com"
    echo "Switched to private account:"
    echo "  user.name:  $(git config --global user.name)"
    echo "  user.email: $(git config --global user.email)"
}

back() {
    wallust run "$@" || return 1
    cat ~/.config/cava/base.conf ~/.config/cava/cava-colors.conf > ~/.config/cava/config
}

cover() {
    local img="$1"
    if [[ ! -f "$img" ]]; then
        echo "Error: Image file not found: $img" >&2
        return 1
    fi

    local files=( *.flac(N) )
    local total=${#files[@]}
    if (( total == 0 )); then
        echo "Error: No .flac files present in current directory" >&2
        return 1
    fi

    local i=1
    for f in "${files[@]}"; do
        local percent=$(( i * 100 / total ))
        printf "[%3d%%] (%d/%d) → %s\n" "$percent" "$i" "$total" "$f"
        metaflac --remove --block-type=PICTURE "$f"
        metaflac --import-picture-from="$img" "$f"
        ((i++))
    done
    echo "Done ($total tracks)"
}

# VPN処理の共通モジュール化（jplay と anime の重複コード削減）
_vpn_wrapper_start() {
    VPN_LAUNCHED_BY_SCRIPT=0
    if ! protonvpn status 2>/dev/null | grep -iq "Status: Connected"; then
        echo "[VPN] Connecting..."
        if protonvpn connect; then
            VPN_LAUNCHED_BY_SCRIPT=1
        else
            echo "[VPN] Failed to connect." >&2
            return 1
        fi
    else
        echo "[VPN] Using existing connection."
    fi

    local ip_info
    if ip_info=$(curl -s --max-time 3 https://ipinfo.io/json); then
        if command -v jq >/dev/null 2>&1; then
            echo "[IP Check] $(echo "$ip_info" | jq -r '"\(.ip) (\(.country) / \(.org))"')"
        else
            echo "[IP Check] Connected."
        fi
    else
        echo "[IP Check] Lookup timeout."
    fi
}

_vpn_wrapper_stop() {
    if [[ "${VPN_LAUNCHED_BY_SCRIPT:-0}" -eq 1 ]]; then
        echo -e "\n[VPN] Disconnecting..."
        protonvpn disconnect
        local count=0
        while protonvpn status 2>/dev/null | grep -iq "Status: Connected"; do
            sleep 0.5
            ((count++))
            ((count >= 10)) && { echo "[VPN] Timeout"; break; }
        done
    fi
    unset VPN_LAUNCHED_BY_SCRIPT
}

jplay() {
    if [[ -z "$1" ]]; then
        echo "Usage: jplay <m3u8_url>" >&2
        return 1
    fi

    _vpn_wrapper_start || return 1
    trap '_vpn_wrapper_stop' EXIT INT TERM

    mpv --no-video \
        --terminal=yes \
        --input-terminal=yes \
        --input-cursor=yes \
        --term-osd-bar=yes \
        --force-seekable=yes \
        --demuxer-max-bytes=500MiB \
        --stream-lavf-o=reconnect=1 \
        --stream-lavf-o=reconnect_at_eof=1 \
        --stream-lavf-o=reconnect_streamed=1 \
        --http-header-fields="Referer: https://japaneseasmr.com/" \
        "$1"

    local exit_code=$?
    trap - EXIT INT TERM
    _vpn_wrapper_stop
    return $exit_code
}

asmr() {
    local list="mazo https://v.weeab0o.xyz/RJ01473335.m3u8
futago https://v.weeab0o.xyz/RJ051890.mp3
jigoku https://v.weeab0o.xyz/RJ260463.mp3
naedoko https://v.weeab0o.xyz/RJ01541752.m3u8"


    local target_url=""
    if [[ -n "$1" ]]; then
        target_url=$(echo "$list" | awk -v kw="$1" '$1 == kw {print $2}')
        if [[ -z "$target_url" ]]; then
            echo "エラー: キーワード '$1' が見つかりません。" >&2
            return 1
        fi
    else
        local selected
        selected=$(echo "$list" | fzf --with-nth=1 --prompt="ASMR Stream > " --height=10 --border)
        [[ -z "$selected" ]] && return 0
        target_url=$(echo "$selected" | awk '{print $2}')
    fi

    jplay "$target_url"
}

anime() {
    _vpn_wrapper_start || return 1
    trap '_vpn_wrapper_stop' EXIT INT TERM

    MPV_FLAGS="--demuxer-max-bytes=500MiB --stream-lavf-o=reconnect=1 --stream-lavf-o=reconnect_at_eof=1 --stream-lavf-o=reconnect_streamed=1" \
    ani-cli "$@"

    local exit_code=$?
    trap - EXIT INT TERM
    _vpn_wrapper_stop
    return $exit_code
}
