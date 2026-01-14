# PowerShell Profile Setup Installed Tools

This document lists all tools, fonts, and modules installed by the `setup.ps1` script for Windows.

| Tool / Module         | Description                                                                 | Installation Method | URL |
|-----------------------|-----------------------------------------------------------------------------|-------------------|-----|
| **gsudo**             | Windows sudo-like elevation tool for running commands as admin.            | Winget            | [GitHub](https://github.com/gerardog/gsudo) |
| **git**               | Version control system for tracking code changes.                           | Winget            | [Git](https://git-scm.com/) |
| **lazygit**           | Terminal-based UI for Git.                                                  | Winget            | [GitHub](https://github.com/jesseduffield/lazygit) |
| **Wget2**             | Fast HTTP/HTTPS downloader.                                                 | Winget            | [GitHub](https://github.com/rockdaboot/wget2) |
| **curl**              | Command-line tool for transferring data via URL.                             | Winget            | [cURL](https://curl.se/) |
| **tar**               | Archive creation and extraction tool.                                       | Winget            | [GnuWin32](http://gnuwin32.sourceforge.net/packages/gtar.htm) |
| **unzip**             | Extracts zip archives.                                                      | Winget            | [GnuWin32](http://gnuwin32.sourceforge.net/packages/unzip.htm) |
| **fzf**               | General-purpose command-line fuzzy finder.                                  | Winget            | [GitHub](https://github.com/junegunn/fzf) |
| **bat**               | `cat` replacement with syntax highlighting and Git integration.            | Winget            | [GitHub](https://github.com/sharkdp/bat) |
| **fd**                | Simple, fast, and user-friendly alternative to `find`.                     | Winget            | [GitHub](https://github.com/sharkdp/fd) |
| **lf**                | Terminal file manager inspired by ranger.                                   | Winget            | [GitHub](https://github.com/gokcehan/lf) |
| **rg (ripgrep)**      | Fast recursive search tool (grep alternative).                              | Winget            | [GitHub](https://github.com/BurntSushi/ripgrep) |
| **delta**             | Syntax-highlighting pager for `git diff` output.                            | Winget            | [GitHub](https://github.com/dandavison/delta) |
| **eza**               | Modern replacement for `ls` with icons and colors.                          | Winget            | [GitHub](https://github.com/eza-community/eza) |
| **zoxide**            | Smart cd command that learns your most used directories.                     | Winget            | [GitHub](https://github.com/ajeetdsouza/zoxide) |
| **starship**          | Cross-shell prompt with minimal configuration and fast startup.             | Winget            | [GitHub](https://starship.rs/) |
| **Neovim (nvim)**     | Terminal-based text editor (modern Vim).                                     | Winget            | [Neovim](https://neovim.io/) |
| **Nerd Fonts (Hack)** | Patched fonts including glyphs/icons for terminal and editors.               | Chocolatey       | [GitHub](https://github.com/ryanoasis/nerd-fonts) |
| **Nerd Fonts (FiraCode)** | Patched fonts including glyphs/icons for terminal and editors.          | Chocolatey       | [GitHub](https://github.com/ryanoasis/nerd-fonts) |
| **Nerd Fonts (JetBrainsMono)** | Patched fonts including glyphs/icons for terminal and editors.    | Chocolatey       | [GitHub](https://github.com/ryanoasis/nerd-fonts) |
| **Terminal-Icons**    | PowerShell module that adds file/folder icons to terminal output.           | PowerShell Module | [PowerShell Gallery](https://www.powershellgallery.com/packages/Terminal-Icons/) |

---

### Notes

- All tools are installed **idempotently**; rerunning the script skips already installed items.
- **Winget packages** are installed silently with accepted agreements.
- **Nerd Fonts** are installed via Chocolatey.
- **Terminal-Icons** module is installed for the current user and ensures PSGallery is trusted.
