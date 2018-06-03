#! /bin/bash
##------------------ DO NOT USE THIS SCRIPT
exit
clear

#---------- Delete existing configutiona files
rm $HOME/.bashrc
rm $HOME/.bash_profile
rm $HOME/.bash_aliases
rm $HOME/.gitconfig
rm $HOME/.config/git/gitignore
rm $HOME/.ssh/config

#---------- Create directories
MOUNT_DIR=~/Mount/1-EEE-ik1614
GIT_CONFIG_DIR=~/.config/git
if [ ! -d "$MOUNT_DIR" ]; then
    mkdir $MOUNT_DIR
fi
if [ ! -d "$GIT_CONFIG_DIR" ]; then
    mkdir $GIT_CONFIG_DIR
fi


#---------- Copy conf files or create symlinks
CPY='cp -r'  # use CPY='ln -sf' for symlinks
$CPY $PWD/dotfiles/bash/bashrc $HOME/.bashrc
$CPY $PWD/dotfiles/bash/bash_profile $HOME/.bash_profile
$CPY $PWD/dotfiles/bash/bash_aliases $HOME/.bash_aliases
$CPY $PWD/dotfiles/bash/scripts $HOME
$CPY $PWD/dotfiles/git/gitconfig $HOME/.gitconfig
$CPY $PWD/dotfiles/git/gitignore-global $HOME/.gitignore-global
$CPY $PWD/dotfiles/ssh/config $HOME/.ssh/config


source ~/.bashrc
