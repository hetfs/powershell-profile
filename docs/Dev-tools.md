# Windows Development Environment

A unified Windows development environment where **PowerShell and CMD share the same binaries** while loading **shell-specific configuration layers**.
Optimized for **WinGet-first installation**, **Chocolatey fallback**, and **fully automated CI/CD workflows**.

---

## Tooling Overview

### Core Shells & Enhancements

| Tool                       | WinGet ID                         | Chocolatey ID       | Repository                                                                 |
| :------------------------- | :-------------------------------- | :------------------ | :------------------------------------------------------------------------- |
| **PowerShell (Core)**      | `Microsoft.PowerShell`            | `powershell-core`   | [PowerShell](https://github.com/PowerShell/PowerShell)                     |
| PSReadLine                 | `Microsoft.PowerShell.PSReadLine` | `psreadline`        | [PSReadLine](https://github.com/PowerShell/PSReadLine)                     |
| **CMD Enhancement:** Clink | `chrisant996.Clink`               | `clink`             | [Clink](https://github.com/chrisant996/clink)                              |
| clink-completions          | —                                 | `clink-completions` | [Clink Completions](https://github.com/vladimir-kotikov/clink-completions) |
| OpenSSH (Client)           | `Microsoft.OpenSSH`               | `openssh`           | [OpenSSH Portable](https://github.com/PowerShell/openssh-portable)         |

---

### Version Control & Collaboration

| Tool       | WinGet ID               | Chocolatey ID | Repository                                          |
| :--------- | :---------------------- | :------------ | :-------------------------------------------------- |
| Git        | `Git.Git`               | `git`         | [Git](https://github.com/git/git)                   |
| lazygit    | `JesseDuffield.lazygit` | `lazygit`     | [Lazygit](https://github.com/jesseduffield/lazygit) |
| GitHub CLI | `GitHub.cli`            | `gh`          | [GitHub CLI](https://github.com/cli/cli)            |
| posh-git   | —                       | `poshgit`     | [Posh-Git](https://github.com/dahlbyk/posh-git)     |
| git-cliff  | `orhun.git-cliff`       | —             | [git-cliff](https://github.com/orhun/git-cliff)     |
| delta      | `dandavison.delta`      | `delta`       | [Delta](https://github.com/dandavison/delta)        |

---

### Shell Productivity & Navigation

| Tool                         | WinGet ID                 | Chocolatey ID | Repository                                       |
| :--------------------------- | :------------------------ | :------------ | :----------------------------------------------- |
| mise (Runtime Manager)       | `jdx.mise`                | `mise`        | [mise](https://github.com/jdx/mise)              |
| Aliae (Alias Manager)        | `JanDeDobbeleer.Aliae`    | —             | [Aliae](https://github.com/JanDeDobbeleer/aliae) |
| fzf (Fuzzy Finder)           | `junegunn.fzf`            | `fzf`         | [fzf](https://github.com/junegunn/fzf)           |
| zoxide (Smart `cd`)          | `ajeetdsouza.zoxide`      | `zoxide`      | [zoxide](https://github.com/ajeetdsouza/zoxide)  |
| fd (Find Alternative)        | `sharkdp.fd`              | `fd`          | [fd](https://github.com/sharkdp/fd)              |
| ripgrep                      | `BurntSushi.ripgrep.MSVC` | `ripgrep`     | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| bat (Cat Clone)              | `sharkdp.bat`             | `bat`         | [bat](https://github.com/sharkdp/bat)            |
| eza (LS Alternative)         | `eza-community.eza`       | `eza`         | [eza](https://github.com/eza-community/eza)      |
| tre (Tree Improved)          | `tre-command`             | `tre-command` | [tre](https://github.com/dduan/tre)              |
| yazi (Terminal File Manager) | `sxyazi.yazi`             | `yazi`        | [yazi](https://github.com/sxyazi/yazi)           |

---

### Prompt, UI & Theming

| Tool                        | WinGet ID           | Chocolatey ID               | Repository                                                      |
| :-------------------------- | :------------------ | :-------------------------- | :-------------------------------------------------------------- |
| Starship Prompt             | `Starship.Starship` | `starship`                  | [Starship](https://github.com/starship/starship)                |
| Terminal-Icons (PowerShell) | —                   | `terminal-icons.powershell` | [Terminal-Icons](https://github.com/devblackops/Terminal-Icons) |

---

### Programming Languages & Runtimes

| Tool                | WinGet ID                   | Chocolatey ID    | Repository                                            |
| :------------------ | :-------------------------- | :--------------- | :---------------------------------------------------- |
| Rust (via rustup)   | `Rustlang.Rustup`           | `rustup.install` | [Rust](https://github.com/rust-lang/rust)             |
| Go                  | `GoLang.Go`                 | `golang`         | [Go](https://github.com/golang/go)                    |
| Python              | `Python.Python.3`           | `python`         | [Python](https://www.python.org)                      |
| Lua                 | `DEVCOM.Lua`                | —                | [Lua](https://www.lua.org)                            |
| Lua Language Server | `LuaLS.lua-language-server` | —                | [LuaLS](https://github.com/LuaLS/lua-language-server) |
| Perl (Strawberry)   | —                           | `strawberryperl` | [Perl](https://www.perl.org)                          |

---

### System Info & Utilities

| Tool                        | WinGet ID                 | Chocolatey ID | Repository                                                       |
| :-------------------------- | :------------------------ | :------------ | :--------------------------------------------------------------- |
| fastfetch                   | `fastfetch-cli.fastfetch` | `fastfetch`   | [fastfetch](https://github.com/fastfetch-cli/fastfetch)          |
| btop4win                    | `aristocratos.btop4win`   | `btop4win`    | [btop4win](https://github.com/aristocratos/btop4win)             |
| tldr (Simplified Man Pages) | `tldr-pages.tldr`         | `tldr`        | [tldr](https://github.com/tldr-pages/tldr)                       |
| glow (Markdown Viewer)      | `charmbracelet.glow`      | `glow`        | [glow](https://github.com/charmbracelet/glow)                    |
| Vale (Linting)              | `errata-ai.Vale`          | `vale`        | [Vale](https://github.com/errata-ai/vale)                        |
| Task (Task Runner)          | `GoTask.Task`             | `go-task`     | [Task](https://github.com/go-task/task)                          |
| Silver Searcher (`ag`)      | —                         | `ag`          | [Silver Searcher](https://github.com/ggreer/the_silver_searcher) |

---

### Network & Web Tools

| Tool                     | WinGet ID             | Chocolatey ID | Repository                                           |
| :----------------------- | :-------------------- | :------------ | :--------------------------------------------------- |
| HTTPie CLI               | `httpie.httpie`       | `httpie`      | [HTTPie](https://github.com/httpie/cli)              |
| HTTP Toolkit             | —                     | —             | [HTTP Toolkit](https://httptoolkit.com)              |
| Globalping               | `jsdelivr.globalping` | `globalping`  | [Globalping](https://github.com/jsdelivr/globalping) |
| dog (DNS Client)         | `ogham.dog`           | `dog`         | [dog](https://github.com/ogham/dog)                  |
| Trivy (Security Scanner) | `AquaSecurity.Trivy`  | `trivy`       | [Trivy](https://github.com/aquasecurity/trivy)       |
| Smallstep CLI (Security) | `smallstep.step`      | `step-cli`    | [Smallstep CLI](https://github.com/smallstep/cli)    |

---

### Terminal Emulators

| Tool             | WinGet ID                   | Chocolatey ID                | Repository                                                |
| :--------------- | :-------------------------- | :--------------------------- | :-------------------------------------------------------- |
| WezTerm          | `wez.wezterm`               | —                            | [WezTerm](https://github.com/wezterm/wezterm)             |
| Windows Terminal | `Microsoft.WindowsTerminal` | `microsoft-windows-terminal` | [Windows Terminal](https://github.com/microsoft/terminal) |
