#!/usr/bin/env bash

cd ~
if [[ $(ls | grep ohmyzshtemp | wc -l) -eq 1 ]]; then
    echo Temp dir exist, abort
    exit 1
fi
mkdir ohmyzshtemp
cd ohmyzshtemp

package_installer=""

# check system and installer
if [[ $(uname -s) == "Darwin" ]]; then
    if [[ $(which brew | wc -l) -eq 1 ]]; then
        package_installer="brew"
    else
        echo No installer found
        rm -rf ~/ohmyzshtemp
        exit 1
    fi
else
    if [[ $(which apt | wc -l) -eq 1 ]]; then
        package_installer="sudo apt -y"
    elif [[ $(which yum | wc -l) -eq 1 ]]; then
        package_installer="sudo yum"
    else
        echo No installer found
        rm -rf ~/ohmyzshtemp
        exit 1
    fi
fi

if [[ $(echo ${package_installer} | wc -w) -eq 0 ]]; then
    echo No installer found
    rm -rf ~/ohmyzshtemp
    exit 1
fi
echo using installer ${package_installer}

# update
echo Updating index
${package_installer} update

echo Upgrading package
${package_installer} upgrade

# check dependencies
if [[ $(which zsh | wc -l) -eq 0 ]]; then
    echo zsh not found, installing zsh
    ${package_installer} install zsh
fi
if [[ $(which git | wc -l) -eq 0 ]]; then
    echo git not found, installing git
    ${package_installer} install git
fi

# download and install oh my zsh
echo Downloading oh-my-zsh install script
if [[ $(which curl | wc -l) -eq 1 ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
elif [[ $(which wget | wc -l) -eq 1 ]]; then
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
else
    echo No downloader found, downloading curl
    ${package_installer} install curl
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# check installation
if [[ $(ls -a ~ | grep .oh-my-zsh | wc -l ) -eq 0 ]]; then
    echo oh my zsh base not found, abort
    rm -rf ~/ohmyzshtemp
    exit 1
fi

# powerline font
echo Installing font
## clone
git clone https://github.com/powerline/fonts.git --depth=1
## install
cd fonts
./install.sh
## clean-up a bit
cd ..
rm -rf fonts

# powerlevel9k
echo Installing theme
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# plugins
echo Installing plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# configure
echo Auto configuring...
mv ~/.zshrc ~/.zshrc_autoconfig_backup
touch ~/.zshrc
echo "## theme settings
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status anaconda context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(ip public_ip time)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=\"╭\"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=\"╰>>> \"
POWERLEVEL9K_ANACONDA_LEFT_DELIMITER=\"\"
POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER=\"\"" >> ~/.zshrc
cat ~/.zshrc_autoconfig_backup >> ~/.zshrc

echo Setup complete
echo Go to .zshrc and change ZSH_THEME to powerlevel9k/powerlevel9k
echo Change terminal font to powerline series to display
echo Use source to add your preference from bash
echo Add plugins to .zshrc with plugins=\(zsh-autosuggestions zsh-syntax-highlighting\)
echo If zsh is not your default login shell, add following command:
echo "
# redirect to zsh
if test -t 1; then
    exec zsh
fi"
rm -rf ~/ohmyzshtemp