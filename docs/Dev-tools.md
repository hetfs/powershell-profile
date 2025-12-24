# Windows Development Environment

A unified Windows development environment where **PowerShell and CMD share the same binaries** while loading **shell-specific configuration layers**.
Built for **WinGet-first installation**, **Chocolatey fallback**, and **fully automated CI/CD workflows**.

---

## Tooling Overview

### Core Shells & Enhancement

| Tool                       | WinGet ID                         | Chocolatey ID       | Repository                                            |
|:-------------------------- |:--------------------------------- |:------------------- |:----------------------------------------------------- |
| **PowerShell** (Core)      | `Microsoft.PowerShell`            | `powershell-core`   | https://github.com/PowerShell/PowerShell              |
| PSReadLine                 | `Microsoft.PowerShell.PSReadLine` | `psreadline`        | https://github.com/PowerShell/PSReadLine              |
| **CMD Enhancement:** Clink | `chrisant996.Clink`               | `clink`             | https://github.com/chrisant996/clink                  |
| clink-completions          | —                                 | `clink-completions` | https://github.com/vladimir-kotikov/clink-completions |
| OpenSSH (Client)           | `Microsoft.OpenSSH`               | `openssh`           | https://github.com/PowerShell/openssh-portable        |

---

### Version Control & Collaboration

| Tool       | WinGet ID               | Chocolatey ID | Repository                               |
|:---------- |:----------------------- |:------------- |:---------------------------------------- |
| Git        | `Git.Git`               | `git`         | https://github.com/git/git               |
| lazygit    | `JesseDuffield.lazygit` | `lazygit`     | https://github.com/jesseduffield/lazygit |
| GitHub CLI | `GitHub.cli`            | `gh`          | https://github.com/cli/cli               |
| posh-git   | —                       | `poshgit`     | https://github.com/dahlbyk/posh-git      |
| git-cliff  | `orhun.git-cliff`       | —             | https://github.com/orhun/git-cliff       |
| delta      | `dandavison.delta`      | `delta`       | https://github.com/dandavison/delta      |

---

### Shell Productivity & Navigation

| Tool                         | WinGet ID                 | Chocolatey ID | Repository                              |
|:---------------------------- |:------------------------- |:------------- |:--------------------------------------- |
| mise (Runtime Manager)       | `jdx.mise`                | `mise`        | https://github.com/jdx/mise             |
| Aliae (Alias Manager)        | `JanDeDobbeleer.Aliae`    | —             | https://github.com/JanDeDobbeleer/aliae |
| fzf (Fuzzy Finder)           | `junegunn.fzf`            | `fzf`         | https://github.com/junegunn/fzf         |
| zoxide (Smarter `cd`)        | `ajeetdsouza.zoxide`      | `zoxide`      | https://github.com/ajeetdsouza/zoxide   |
| fd (Find Alternative)        | `sharkdp.fd`              | `fd`          | https://github.com/sharkdp/fd           |
| ripgrep                      | `BurntSushi.ripgrep.MSVC` | `ripgrep`     | https://github.com/BurntSushi/ripgrep   |
| bat (Cat Clone)              | `sharkdp.bat`             | `bat`         | https://github.com/sharkdp/bat          |
| eza (LS Alternative)         | `eza-community.eza`       | `eza`         | https://github.com/eza-community/eza    |
| tre (Tree Improved)          | `tre-command`             | `tre-command` | https://github.com/dduan/tre            |
| yazi (Terminal File Manager) | `sxyazi.yazi`             | `yazi`        | https://github.com/sxyazi/yazi          |

---

### Prompt, UI & Theming

| Tool                        | WinGet ID           | Chocolatey ID               | Repository                                    |
|:--------------------------- |:------------------- |:--------------------------- |:--------------------------------------------- |
| Starship Prompt             | `Starship.Starship` | `starship`                  | https://github.com/starship/starship          |
| Terminal-Icons (PowerShell) | —                   | `terminal-icons.powershell` | https://github.com/devblackops/Terminal-Icons |

---

### Programming Languages & Runtimes

| Tool                | WinGet ID                   | Chocolatey ID    | Repository                                   |
|:------------------- |:--------------------------- |:---------------- |:-------------------------------------------- |
| Rust (via rustup)   | `Rustlang.Rustup`           | `rustup.install` | https://github.com/rust-lang/rust            |
| Go                  | `GoLang.Go`                 | `golang`         | https://github.com/golang/go                 |
| Python              | `Python.Python.3`           | `python`         | https://www.python.org                       |
| Lua                 | `DEVCOM.Lua`                | —                | https://www.lua.org                          |
| Lua Language Server | `LuaLS.lua-language-server` | —                | https://github.com/LuaLS/lua-language-server |
| Perl (Strawberry)   | —                           | `strawberryperl` | https://www.perl.org                         |

---

### System Info & Utilities

| Tool                        | WinGet ID                 | Chocolatey ID | Repository                                    |
|:--------------------------- |:------------------------- |:------------- |:--------------------------------------------- |
| fastfetch                   | `fastfetch-cli.fastfetch` | `fastfetch`   | https://github.com/fastfetch-cli/fastfetch    |
| btop4win                    | `aristocratos.btop4win`   | `btop4win`    | https://github.com/aristocratos/btop4win      |
| tldr (Simplified Man Pages) | `tldr-pages.tldr`         | `tldr`        | https://github.com/tldr-pages/tldr            |
| glow (Markdown Viewer)      | `charmbracelet.glow`      | `glow`        | https://github.com/charmbracelet/glow         |
| Vale (Linting)              | `errata-ai.Vale`          | `vale`        | https://github.com/errata-ai/vale             |
| Task (Task Runner)          | `GoTask.Task`             | `go-task`     | https://github.com/go-task/task               |
| Silver Searcher (`ag`)      | —                         | `ag`          | https://github.com/ggreer/the_silver_searcher |

---

### Network & Web Tools

| Tool                     | WinGet ID             | Chocolatey ID | Repository                             |
|:------------------------ |:--------------------- |:------------- |:-------------------------------------- |
| HTTPie CLI               | `httpie.httpie`       | `httpie`      | https://github.com/httpie/cli          |
| HTTP Toolkit             | `httptoolkit`         | —             | https://httptoolkit.com                |
| Globalping               | `jsdelivr.globalping` | `globalping`  | https://github.com/jsdelivr/globalping |
| dog (DNS Client)         | `ogham.dog`           | `dog`         | https://github.com/ogham/dog           |
| Trivy (Security Scanner) | `AquaSecurity.Trivy`  | `trivy`       | https://github.com/aquasecurity/trivy  |
| Smallstep CLI (Security) | `smallstep.step`      | `step-cli`    | https://github.com/smallstep/cli       |

---

### Terminal Emulators

| Tool             | WinGet ID                   | Chocolatey ID                | Repository                            |
|:---------------- |:--------------------------- |:---------------------------- |:------------------------------------- |
| WezTerm          | `wez.wezterm`               | —                            | https://github.com/wezterm/wezterm    |
| Windows Terminal | `Microsoft.WindowsTerminal` | `microsoft-windows-terminal` | https://github.com/microsoft/terminal |

---

### Editors & Development Utilities

| Tool                        | WinGet ID                                   | Chocolatey ID | Repository                                                   |
|:--------------------------- |:------------------------------------------- |:------------- |:------------------------------------------------------------ |
| Neovim                      | `Neovim.Neovim`                             | —             | https://neovim.io                                            |
| Yank Note (Markdown Editor) | `purocean.YankNote`                         | —             | https://github.com/purocean/yn                               |
| EditorConfig Checker        | `EditorConfig-Checker.EditorConfig-Checker` | —             | https://github.com/editorconfig-checker/editorconfig-checker |
| Config Validator            | `Boeing.config-file-validator`              | —             | https://github.com/Boeing/config-file-validator              |

---

### Data Processing & CLI Tools

| Tool                  | WinGet ID      | Chocolatey ID | Repository                        |
|:--------------------- |:-------------- |:------------- |:--------------------------------- |
| jq (JSON)             | `jqlang.jq`    | `jq`          | https://github.com/jqlang/jq      |
| yq (YAML/XML/JSON)    | `MikeFarah.yq` | `yq`          | https://github.com/mikefarah/yq   |
| ytt (YAML Templating) | `Carvel.ytt`   | `ytt`         | https://github.com/carvel-dev/ytt |

---

### Multimedia & Graphics Tools

| Tool                   | WinGet ID                 | Chocolatey ID | Repository                                        |
|:---------------------- |:------------------------- |:------------- |:------------------------------------------------- |
| FFmpeg                 | `Gyan.FFmpeg`             | `ffmpeg`      | https://www.gyan.dev/ffmpeg                       |
| ImageMagick            | `ImageMagick.ImageMagick` | `imagemagick` | https://github.com/ImageMagick/ImageMagick        |
| yt-dlp                 | `yt-dlp.yt-dlp`           | `yt-dlp`      | https://github.com/yt-dlp/yt-dlp                  |
| Poppler (PDF Tools)    | `oschwartz10612.Poppler`  | —             | https://github.com/oschwartz10612/poppler-windows |
| Chafa (Image to Text)  | `hpjansson.Chafa`         | —             | https://hpjansson.org/chafa                       |
| Editly                 | —                         | `editly`      | https://github.com/mifi/editly                    |
| Auto-Editor            | —                         | `auto-editor` | https://github.com/WyattBlue/auto-editor          |
| Signet (Audio Editing) | —                         | `signet`      | https://github.com/SamWindell/Signet              |

---

## Automated Installer Matrix

```yaml
windows:
  package_managers:
    primary: winget
    fallback: chocolatey

  shells:
    powershell:
      tools:
        - git
        - lazygit
        - gh
        - git-cliff
        - vale
        - task
        - direnv
        - step
        - trivy
        - openssh
        - mise
        - rustup
        - golang
        - python
        - lua
        - psreadline
        - psfzf
        - zoxide
        - fd
        - ripgrep
        - bat
        - eza
        - delta
        - tre
        - yazi
        - starship
        - posh-git
        - terminal-icons
        - fastfetch
        - btop4win
        - tldr
        - glow
        - ag
        - httpie
        - globalping
        - dog
        - editly
        - auto-editor
        - chafa
        - ffmpeg
        - poppler
        - jq
        - yt-dlp
        - imagemagick
        - signet

    cmd:
      tools:
        - clink
        - clink-completions

  terminals:
    - windows-terminal
```


https://github.com/koalaman/shellcheck?tab=readme-ov-file#installing
