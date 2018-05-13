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
mkdir $HOME/Mount
mkdir $HOME/Mount/1-EEE-ik1614
mkdir $HOME/.config/git

#---------- Copy conf files or create symlinks
CPY='cp -r'  # use CPY='ln -sf' for symlinks
$CPY $PWD/bash/bashrc $HOME/.bashrc
$CPY $PWD/bash/bash_profile $HOME/.bash_profile
$CPY $PWD/bash/bash_aliases $HOME/.bash_aliases
$CPY $PWD/bash/scripts $HOME/scripts
$CPY $PWD/git/gitconfig $HOME/.gitconfig
$CPY $PWD/git/gitignore $HOME/.config/git/gitignore
$CPY $PWD/ssh/config $HOME/.ssh/config


source ~/.bashrc
