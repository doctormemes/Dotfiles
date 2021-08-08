# Doc's Zsh Dotfiles (Parrot OS personalized)
#### My Parrot Linux Zsh dotfiles (plus an install script for automatically setting them up)

Keep in mind I've attempted to keep everything POSIX compliant, but as much as I'd like this dotfiles install to be able to be run on any system, I don't yet know enough about this sort of thing, and so I have to warn anyone not using Parrot OS that you may encounter issues.

## ***If you don't wish to use my Parrot OS personalized powerlevel10k prompt theme, you have two options:***
 - Go into .zshrc and change `P10K_PROMPT="docstheme"` to `P10K_PROMPT=p10k` instead. After restarting your shell, just follow the prompts to set up your own Powerlevel10k prompt
 - Continue using my `.docstheme.zsh` Powerlevel10k prompt config file and just reconfigure it using `p10k configure` 

## I've tested the install.sh installer on Debian, Kali Linux, and Parrot OS.

 - **It *SHOULD* work without issue on most distros.**

 - Be sure to **BACK UP YOUR FILES** for your shell's configuration **BEFORE running the script.**

# **I am not responsible for anything undesirable that happens as a result of you using any of the files in this repo.**

-------------------------------------------------------------------------------------------------------------------------------

## INSTALL REQUIREMENTS: zsh, git, neofetch, wget
I'd also recommend installing autojump, fzf, and thefuck, as the OMZ plugins for them are in the repo zshrc file.
If you don't intend to use any of these, I recommend going into .zshrc and removing them from the plugins portion of the file so you don't see OMZ complaining about them not being installed.

### Choose a particular powerlevel10k prompt config file
You see a custom prompt file that someone else has set up for P10K and you decide you'd like to use it.
Normally, you'd have to go into .zshrc, after knowing where this P10K file is located, and source it, or copy and paste the entire file into your .zshrc and clutter it up.

Well, I didn't really like having to do any of that every time I wanted to change my zsh p10k prompt, so I created a plugin (called p10k-promptconfig) that will get cloned into oh-my-zsh's custom plugins directory. The plugin handles using any .<theme_name>.zsh files located in the same directory as .zshrc, and as long as you have `P10K_PROMPT="<theme_name>"` set in .zshrc. The plugin will fallback to sourcing the good ole .p10k.zsh file if the custom prompt theme cannot be found for sourcing. If there is no .p10k.zsh file, the plugin will ask if you'd like to use p10k configure to create one.

So, simply set the P10K_PROMPT variable in .zshrc and the plugin will do the rest.

### Be sure to add a . to the front of and .zsh to the end of the name of whatever p10k theme files you wanna use, otherwise there will likely be problems.
Example: To use my prompt theme (.docstheme.zsh) you simply add to .zshrc: `P10K_PROMPT="docstheme"`

#### The help command is useful again when run without any arguments
Now, somewhat like with bash, it will display information about useful command aliases and other useful information.

I will likely add more information for it to display in the future, but for now at least it isn't just saying "no help topic available for this" (or whatever it says when run without arguments)
