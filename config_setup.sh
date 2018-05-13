#! /bin/bash
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
$CPY $PWD/bash/bashrc $HOME/.bashrc
$CPY $PWD/bash/bash_profile $HOME/.bash_profile
$CPY $PWD/bash/bash_aliases $HOME/.bash_aliases
$CPY $PWD/bash/scripts $HOME
$CPY $PWD/git/gitconfig $HOME/.gitconfig
$CPY $PWD/git/gitignore $HOME/.config/git/gitignore
$CPY $PWD/ssh/config $HOME/.ssh/config


source ~/.bashrc
