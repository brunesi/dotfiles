# Setting up PowerShell 7

## Installation:

1. Visit the PowerShell GitHub releases page: [https://github.com/PowerShell/PowerShell/releases](https://github.com/PowerShell/PowerShell/releases)
2. Download the `.msi` installer for Windows, e.g. PowerShell-7.3.9-win-x64.msi
3. Run the installer and follow the on-screen instructions.

## Setting up the Profile:

1. Copy the `Microsoft.PowerShell_profile.ps1` from this repository to `$HOME/Documents/PowerShell/`.
2. Open PowerShell 7, and the profile should be applied automatically.


## Cloning locally and editing in PowerShell:

1. **Cloning the `dotfiles` Repository:**

   a. Open PowerShell.

   b. Navigate to the directory where you want to clone the repository. For example, if you want to clone it to a directory called `github` in your `Documents`:
   ```powershell
   cd $HOME\Documents
   New-Item -Type Directory -Name github
   cd github
   ```

   c. Clone your `dotfiles` repository. Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username:
   ```powershell
   git clone https://github.com/YOUR_GITHUB_USERNAME/dotfiles.git
   ```

   d. Navigate into the cloned repository:
   ```powershell
   cd dotfiles
   ```

2. **Updating the Repository with PowerShell Profile and Documentation:**

   a. Copy your PowerShell profile to this directory:
   ```powershell
   Copy-Item $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 .\
   ```

   b. Create a new text file named `powershell_setup.md` in the `dotfiles` directory. You can use an editor like `notepad` or any other text editor you prefer:
   ```powershell
   notepad.exe .\powershell_setup.md
   ```

   In the opened notepad, you can then document the steps for installing PowerShell 7 and setting up the profile, as previously mentioned.

   c. Once you've saved and closed the text file, commit and push the changes to GitHub:
   ```powershell
   git add Microsoft.PowerShell_profile.ps1
   git add powershell_setup.md
   git commit -m "Added PowerShell 7 profile and setup documentation"
   git push origin main
   ```

After these steps, both your PowerShell profile and the installation/setup steps will be available in your `dotfiles` repository on GitHub, even from your home machine.