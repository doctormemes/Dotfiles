#!/bin/bash

# variables
CLONED_REPO=$(dirname "$0")
CLONED_REPO=$(cd "$CLONED_REPO" && pwd)
INSTALL_DIRECTORY="$HOME/.config/zsh"

# functions
function clone_to_omz()
{
    type=$1 # repo type, either plugins or themes
    repo=$2
    name=$(echo "${repo##*/}" | cut -f 1 -d '.')
    if [ -d "$ZSH/custom/$type/$name" ]; then
        cd "$ZSH/custom/$type/$name" && git pull
    else
        git clone --depth=1 "$repo" "$ZSH/custom/$type/$name"
    fi
}

function font_install(){
    font=$1
    link=$2
    fontname=$(echo "${font//\\}" | cut -f 1 -d '.')
    if [[ -f "$HOME/.fonts/$font" ]]; then
        printf "%s\n" "$fontname already installed"
    else
        printf "%s\n" "Installing $fontname..."
        wget -q --show-progress -N "$link" -P "$HOME/.fonts/"
    fi
}

# ============BEGIN============
# check if necessary packages are installed
req_pkgs=(zsh git wget neofetch)

for i in "${req_pkgs[@]}"; do
    if command -v "$i" > /dev/null 2>&1; then
        printf "%s\n" "$i already installed"
    else
        if sudo apt install -y "$i" || sudo pacman -S "$i" || sudo dnf install -y "$i" || sudo yum install -y "$i" || pkg install "$i" || apt-cyg install "$i"; then
            printf "%s\n" "$i installed."
        else
	    if (( $+commands[apt-cyg] )); then
		printf "%s\n" "apt-cyg package manager detected, since it does not have a neofetch package we will skip it."
	    else
                printf "%s %s\n" "Please install the following packages first, then try again:" "${req_pkgs[*]}" && exit
	    fi
        fi
    fi
done

# MINICONDA INSTALL
if [ -f "$HOME/miniconda3/condabin/conda" ]; then
    printf "Miniconda3 is already installed.\n"
else
    printf "Miniconda3 is not installed.\n"
    while true; do
        read -rp "Do you want to install Miniconda? [Y/n]: " yn
        case $yn in
            [Yy]* )
                printf "Be sure to install Miniconda3 within your user's home directory.\n"
                if [ -f "$HOME/Miniconda3-latest-Linux-x86_64.sh" ]; then # to prevent downloading Miniconda3 setup file multiple times
                    printf "Miniconda3 is already downloaded\n"
                else
                    printf "%+57s\n" "Downloading Miniconda3..."
                    wget -q --show-progress https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P ~
                    printf "%+50s\n" "Download finished."
                fi
                printf "Starting Miniconda3 setup...\n"
                bash ~/Miniconda3-latest-Linux-x86_64.sh
                break ;;
            [Nn]* )
                printf "Answer: No.\n"
                printf "Continuing...\n" && sleep 1
                break ;;
            * )
                printf "Please provide a valid answer.\n" ;;
        esac
    done
fi

# MINICONDA INSTALL FILE CLEANUP
if [[ -f "$HOME/miniconda3/condabin/conda" && -f "$HOME/Miniconda3-latest-Linux-x86_64.sh" ]]; then
    rm -f "$HOME/Miniconda3-latest-Linux"*
fi

# ASK TO BACKUP FILES --- ZSH CONFIG INSTALLS BEGIN AFTER THIS
while true; do
    printf "During this install, any zsh related dotfiles (such as .zshrc, .zshenv) in user's home directory will be deleted.\n"
    printf "Are there dotfiles in your home directory that you want to backup?\n"
    read -rp "Backup existing dotfiles in home directory? [Y/n]: " yn
    case $yn in
        [Yy]* )
            printf "Starting backup...\n"
            mkdir -p "$HOME/Backup_Dotfiles" # Create file backup directory
            if [ -f "$HOME/.zprofile" ]; then
                printf "%s\n" "Found .zprofile, backing up file to $HOME/Backup_Dotfiles..."
                cp "$HOME/.zprofile" "$HOME/Backup_Dotfiles/.zprofile-backup-$(date +"%Y-%m-%d")"
                printf "%s\n" "Backed up current .zprofile to .zprofile-backup-$(date +"%Y-%m-%d")"
            fi
            if [ -f "$HOME/.zshenv" ]; then
                printf "%s\n" "Found .zshenv, backing up file to $HOME/Backup_Dotfiles..."
                cp "$HOME/.zshenv" "$HOME/Backup_Dotfiles/.zshenv-backup-$(date +"%Y-%m-%d")"
                printf "%s\n" "Backed up current .zshenv to .zshenv-backup-$(date +"%Y-%m-%d")"
            fi
            if [ -f "$HOME/.zshrc" ]; then # backup .zshrc
                printf "%s\n" "Found .zshrc, backing up file to $HOME/Backup_Dotfiles..."
                cp "$HOME/.zshrc" "$HOME/Backup_Dotfiles/.zshrc-backup-$(date +"%Y-%m-%d")"
                printf "%s\n" "Backed up current .zshrc to .zshrc-backup-$(date +"%Y-%m-%d")"
            fi
            printf "Finished backing up any existing zsh files. Continuing...\n" && sleep 1
            break ;;
        [Nn]* )
            printf "Continuing without backing up existing zsh files...\n" && sleep 1
            break ;;
        * )
            printf "Please provide a valid answer.\n" ;;
    esac
done

# CHOOSE INSTALL DIRECTORY
while true; do
    printf "\n%s\n" "Where should your zsh and oh-my-zsh configuration files be installed?"
    printf "%s\n" "Default install directory is: $INSTALL_DIRECTORY"
    printf "  - %s\n" "Press ENTER to confirm the location" "Press CTRL-C to abort the installation" "Or specify a different location below"
    printf "[%s] >>> " "$INSTALL_DIRECTORY"
    read -r user_prefix
    if [ "$user_prefix" != "" ]; then
        case "$user_prefix" in
            *\ * )
                printf "ERROR: Cannot install into directories with spaces\n" >&2
                continue ;;
            *)
                eval INSTALL_DIRECTORY="$user_prefix" ;;
        esac
    fi
    # check if user entry contained spaces
    case "$INSTALL_DIRECTORY" in
        *\ * )
            printf "ERROR: Cannot install into directories with spaces\n" >&2
            continue ;;
    esac
    # if directory exists, don't try creating it
    if [ -e "$INSTALL_DIRECTORY" ]; then
        printf "\n%s\n" "Directory already exists, no need to create it."
        break
    else
        if mkdir -p "$INSTALL_DIRECTORY" 2>/dev/null; then
            printf "\n%s\n" "Directory created." && ls -ld "$INSTALL_DIRECTORY" && sleep 1
            break
        else # let user know we couldn't create directory
            printf "%s\n%s\n%s\n" '!-------------------------!' "Couldn't create directory: $INSTALL_DIRECTORY" '!-------------------------!'
            printf "Make sure you have the correct permissions to create the directory.\n" && sleep 1
            INSTALL_DIRECTORY=$HOME/.config/zsh
            continue
        fi
    fi
done

# Oh-My-ZSH INSTALL
printf "\n%s\n" "Installing oh-my-zsh into $INSTALL_DIRECTORY" && sleep 1
export ZSH=$INSTALL_DIRECTORY/.oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then # OMZ already installed, but located in user's home dir
    printf "%s\n" "oh-my-zsh is already installed in home directory, moving to new $INSTALL_DIRECTORY directory..."
    mv "$HOME/.oh-my-zsh" "$INSTALL_DIRECTORY"
    cd "$INSTALL_DIRECTORY/.oh-my-zsh" && git pull
else
    if [ -d "$INSTALL_DIRECTORY/.oh-my-zsh" ]; then # OMZ installed in install dir
        printf "%s\n" "oh-my-zsh is already installed in $INSTALL_DIRECTORY."
        cd "$INSTALL_DIRECTORY/.oh-my-zsh" && git pull
    else
        printf "oh-my-zsh is not installed. Installing...\n" # OMZ not installed
        sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended
    fi
fi

printf "\n%+50s\n\n" "READY TO INSTALL OhMyZSH PLUGINS" && sleep 1

if [ ! -d "$INSTALL_DIRECTORY/.oh-my-zsh" ]; then
    printf "%s\n" "Something's wrong, oh-my-zsh isn't in $INSTALL_DIRECTORY..."
    printf "Checking if oh-my-zsh is in home directory...\n" && sleep 1
    if [ -d ~/.oh-my-zsh ]; then
        printf "%s\n" "oh-my-zsh is in home directory, will move it to $INSTALL_DIRECTORY..."
        mv "$HOME/.oh-my-zsh" "$INSTALL_DIRECTORY" && printf "%s\n" "oh-my-zsh directory moved to $INSTALL_DIRECTORY, can proceed now" && sleep 1
    else
        printf "oh-my-zsh is NOT in correct directory, something is wrong\n"
        printf "Exitting before attempting anything further\n" && sleep 1
        exit
    fi
else # INSTALL (or update) OMZ PLUGINS
    clone_to_omz plugins https://github.com/doctormemes/add-to-omz.git
    clone_to_omz plugins https://github.com/doctormemes/p10k-promptconfig.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-autosuggestions.git
    clone_to_omz plugins https://github.com/esc/conda-zsh-completion.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-syntax-highlighting.git
    clone_to_omz plugins https://github.com/marlonrichert/zsh-autocomplete.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-history-substring-search.git
    clone_to_omz themes https://github.com/romkatv/powerlevel10k.git
fi

# INSTALL EMOJI FONTS IF NONE FOUND
if fc-list | grep -i emoji >/dev/null; then
    printf "Emoji fonts found, won't install any more. If emojis are missing try downloading fonts-noto-color-emoji and fonts-recommended packages\n" && sleep 1
else
    if sudo apt install -y fonts-noto-color-emoji fonts-recommended || sudo pacman -S fonts-noto-color-emoji fonts-recommended || sudo dnf install -y fonts-noto-color-emoji fonts-recommended || sudo yum install -y fonts-noto-color-emoji fonts-recommended || pkg install fonts-noto-color-emoji fonts-recommended;
    then
        printf "Fonts to show latest emojis are installed\n"
    else
        printf "Couldn't install fonts, latest emojis may not show correctly\n"
    fi
fi

# INSTALL NERD FONTS
while true; do
    printf "\nWould you like to install nerd fonts?\n"
    read -rp "Install nerd fonts? [Y/n]: " yn
    case $yn in
        [Yy]* )
            # Meslo LG S Regular Nerd Font
            font_install "Meslo LG S Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Regular/complete/Meslo%20LG%20S%20Regular%20Nerd%20Font%20Complete.ttf

            # DejaVu Sans Mono Nerd Font
            font_install "DejaVu Sans Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf

            # Roboto Mono Nerd Font
            font_install "Roboto Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf

            # Hack Regular Nerd Font
            font_install "Hack Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf

            # Sauce Code Pro Nerd Font
            font_install "Sauce Code Pro Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete.ttf

            # Scan new fonts and build font information cache files
            fc-cache -fv "$HOME/.fonts"
            break ;;
        [Nn]* )
            printf "\nWill not install Nerd Fonts. Continuing...\n";
            break ;;
        * )
            printf "\nPlease provide a valid answer.\n" ;;
    esac
done

# START TO COPY FILES FROM REPO
# First copy omz-files directory to $INSTALL_DIRECTORY
cp -r "$CLONED_REPO/omz-files" "$INSTALL_DIRECTORY"

# create completions directory in .oh-my-zsh if needed
[ ! -d "$INSTALL_DIRECTORY/.oh-my-zsh/completions" ] && mkdir -p "$ZSH/completions"

# Start operations within omz-files directory
for i in "$INSTALL_DIRECTORY/omz-files/"*; do
    # copy completion file to oh-my-zsh
    [[ "$i" = *"_better-help" ]] && cp -uv "$i" "$ZSH/completions"
    # if miniconda is installed, need to copy conda_setup.zsh
    [[ "$i" = *"conda_init.zsh" && -f "$HOME/miniconda3/condabin/conda" ]] && cp -uv "$i" "$ZSH/custom"
    # copy nordvpn plugin to custom plugins directory (nordvpn plugin is yet to be included in oh-my-zsh outside of it's testing branch)
    [ -d "$i" ] && cp -ruv "$i" "$INSTALL_DIRECTORY/.oh-my-zsh/custom/plugins"
done && sleep 1

# copy regular files
for i in "$CLONED_REPO"/* ; do
    if [[ -f "$i" && ("$i" != *"LICENSE" && "$i" != *"install.sh") ]]; then
        printf "\n%s\n" "Copying $i to $INSTALL_DIRECTORY"
        cp -fv "$i" "$INSTALL_DIRECTORY"
    fi
done

# copy hidden files
for i in "$CLONED_REPO"/.* ; do
    if [[ -f "$i" && "$i" != *".gitignore" ]]; then
        printf "\n%s\n" "Copying $i to $INSTALL_DIRECTORY"
        cp -fv "$i" "$INSTALL_DIRECTORY"
    fi
done

printf "%s\n" "Finished setting up repo files in new $INSTALL_DIRECTORY directory." && sleep 1
# Remove remaining zsh files in $HOME directory (if the install directory isn't $HOME)
if [ "$INSTALL_DIRECTORY" != "$HOME" ]; then
    printf "Removing remaining .zsh* dotfiles in user's home directory...\n"
    rm -fv "$HOME/.zsh"*
    printf "Done\n" && sleep 1
fi

cd "$HOME" || exit

PARTIAL_DIRECTORY="${INSTALL_DIRECTORY#$HOME/}"

while true; do
    printf "\n%s\n\v%s\n" "Zsh, by default, looks for zshrc, zshenv, etc.. in the user's home directory, so we set the ZDOTDIR variable required to let Zsh know where to look for these files." "We can symlink the zshenv file with the export ZDOTDIR line in it to your home directory from your $INSTALL_DIRECTORY directory, or we can export the variable in /etc/zsh/zshenv (this is my preferred method)."
    printf "\nIf you'd prefer not to set it, or to set it yourself some other way, press enter.\n"
    printf "\n%+50s\n" "OPTIONS:"
    printf "\t%s\t%s\n" "[1]" "Create symbolic link to $INSTALL_DIRECTORY/.zshenv in $HOME directory and append line exporting ZDOTDIR in it"
    printf "\t%s\t%s\n" "[2]" "Use /etc/zsh/zshenv file to set ZDOTDIR to $INSTALL_DIRECTORY (may require sudo priviledges)"
    printf "\t[Enter] \tDo nothing; ZDOTDIR is already set, or I am going to set the ZDOTDIR variable myself.\n"
    printf "\t>>> "
    read -r choice
    INSERT_TEXT="[[ -z \"\$ZDOTDIR\" && -f ~/$PARTIAL_DIRECTORY/.zshrc ]] && export ZDOTDIR=~/$PARTIAL_DIRECTORY"
    case $choice in
        [1] )
            INSERT_TEXT="[[ -z \"\$ZDOTDIR\" && -f ~/$PARTIAL_DIRECTORY/.zshrc ]] && export ZDOTDIR=~/$PARTIAL_DIRECTORY"
            printf "\nCreated symbolic link in home directory:\n"
            ln -sv "$INSTALL_DIRECTORY/.zshenv" "$HOME/.zshenv"
            printf "Inserting lines to export ZDOTDIR into .zshenv file...\n"
            printf "\n%s\n" "$INSERT_TEXT" | tee -a "$HOME/.zshenv" > /dev/null
            printf "%s\n" "$HOME/.zshenv will set and export ZDOTDIR"
            printf "%s\n" '!!!IMPORTANT: YOU WILL NEED TO MODIFY THIS FILE IF YOU CHANGE YOUR ZDOTDIR DIRECTORY LOCATION!!!' && sleep 2
            break ;;
        [2] )
            INSERT_TEXT="[[ -z \"\$ZDOTDIR\" && -f ~/$PARTIAL_DIRECTORY/.zshrc ]] && export ZDOTDIR=~/$PARTIAL_DIRECTORY"
            printf "\n%s\n" "$INSERT_TEXT" | sudo tee -a /etc/zsh/zshenv > /dev/null
            echo -e "$INSERT_TEXT" | sudo tee -a /etc/zsh/zshenv > /dev/null
            printf "/etc/zsh/zshenv will set and export ZDOTDIR\n"
            printf "%s\n" '!!!IMPORTANT: YOU WILL NEED TO MODIFY THIS FILE IF YOU CHANGE YOUR ZDOTDIR DIRECTORY LOCATION!!!' && sleep 2
            break ;;
        "" )
            printf "Nothing will be done. Continuing on to final steps...\n" && sleep 1
            break ;;
        * )
            printf "\nPlease enter a valid choice.\n" ;;
    esac
done

if [[ "$INSTALL_DIRECTORY" != "$HOME" && -z "$ZDOTDIR" ]]; then
export ZDOTDIR="$INSTALL_DIRECTORY"
elif [[ "$INSTALL_DIRECTORY" == "$HOME" && -z "$ZDOTDIR" ]]; then
export ZDOTDIR=${ZDOTDIR:-$HOME}
fi

while true; do
    printf "\tWould you like to use my personal docstheme powerlevel10k shell prompt file, personalized for Parrot OS?\n\n"
    printf "\tIf not, your installation will use a standard p10k powerlevel10k shell prompt file that you can always change and reconfigure.\n"
    printf "\t(You can configure the prompt by running the \`p10k configure\` command.)\n"
    printf "\t(Go back to using docstheme by simply changing the P10K_PROMPT environment variable in your .zshrc file)\n\n"
    printf "\tDo you want to use the docstheme powerlevel10k prompt config file?\n"
    printf "\t(Y/N)>>> "
    read -r yn
    case $yn in
        [Yy]* )
            printf "\nOkay, will use docstheme.zsh file.\n" 
            break ;;
        [Nn]* )
            sed -i 's/\(^P10K_PROMPT=\).*/\1"p10k"/' "$ZDOTDIR/.zshrc"
            printf "\nOkay, will use p10k.zsh file.\nRemember to run p10k configure to configure it to your liking.\n"
            break ;;
        * )
            printf "\nPlease provide a valid answer (Y or N)\n" ;;
    esac
done


# Check if default shell is zsh
if [[ "$SHELL" != *"/zsh" ]]; then
    # Change default shell to zsh & run omz update
    printf "Sudo access is needed to change default shell\n"
    if chsh -s "$(which zsh)" && $(which zsh) -i -c 'omz update'; then
        printf "Installation Successful, exit terminal and enter a new session\n"
    else
        printf "Something went wrong\n"
    fi
else
    printf "%s\n" "Default shell is already $(which zsh)"
    printf "Updating oh-my-zsh\n" && sleep 1
    if $(which zsh) -i -c 'omz update'; then
        printf "Installation Successful, exit terminal and enter a new session\n"
    else
        printf "Something went wrong\n"
    fi
fi

exit
