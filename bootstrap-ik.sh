#! /bin/bash
clear

manual(){
echo "====================================================="
cat << EOF
usage: $0 [-h?] [-c] [-b]

BASIC OPTIONS:
   -h         Show this message
ADVANCED OPTIONS:
   -c         Copy the files rather than creating symbolic links.
   -b	      Back up current configuration files
By Ilya Kisil <ilyakisil [at] gmail.com>
EOF
echo "====================================================="
}


##########################################
###--------   Default values   --------###
##########################################
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BROWN="\033[0;33m"
WHITE="\033[0;0m"

DATE=`date '+%Y-%m-%d_%H-%M-%S'`
OS=`uname`
DFH="$PWD"

# Create symlink as default
COPY_FILES=0;
COPY="ln -sf"

BACKUP=1;
BACKUP_DIR="$HOME/config_$DATE"

while getopts "hcb" OPTION;
do
	case $OPTION in
		h|\?)
			manual
			exit 0
			;;
		c) COPY_FILES=1
			;;
		b) BACKUP=1
			;;
	esac
done

#########################################
###--------     Functions     --------###
#########################################
backup_config(){
    echo "backup_config"
    exit

    ###################
    README="$BACKUP_DIR/README.md"
    mkdir $BACKUP_DIR
    echo "Backup of configuration existed at $DATE:\n\n" > $README
    declare -a BACK_UP=(".ssh"
                        ".gitconfig"
                        ".gitignore-global"
                        ".tmux.conf"
                        ".zshrc"
                        )
    for name in "${BACK_UP[@]}"
    do
        config_file="$HOME/$name"
        echo $config_file
        if [[ -f $config_file ]]; then
            cp -r $config_file $BACKUP_DIR
            echo "Copied $config_file" >> $README
        elif [[ -d $config_file ]]; then
            cp -r $config_file $BACKUP_DIR
            echo "Copied $config_file" >> $README
        elif [[ -L $config_file ]]; then
            echo "Did not copy $config_file. It was a symlink" >> $README
        else
            echo "Config file $config_file did not exist" >> $README
        fi
    done
}

clean_config(){
    echo "clean_config"
    exit

    ############
    # rm $HOME/.tmux.conf
    # rm $HOME/.zshrc
    # rm $HOME/.gitconfig
    # rm $HOME/.gitignore-global
    # rm $HOME/.ssh/config
}

ssh_bootstrap(){
    echo "ssh_bootstrap"
    exit

    ###############
    # setup ssh config
    SSH_CONFIG_HOME="$HOME/.ssh"
    if [[ ! -d $SSH_CONFIG_HOME ]]; then
        mkdir  $SSH_CONFIG_HOME
    fi
    $COPY $DHF/dotfiles/ssh/config $HOME/.ssh/config

    # create ssh keys
    declare -a SSH_KEYS=("github_IlyaKisil"
                         "gitlab_ik1614"
                         "eee_ubuntu_ik1614"
                         )
    for name in "${SSH_KEYS[@]}"
    do
        ssh_key="$HOME/.ssh/$name"
        if [ ! -f $ssh_key ]; then
            echo -e "Creating SSH key in ${GREEN} $ssh_key ${WHITE}"
            ssh-keygen -t rsa -b 4096 -C "ilyakisil@gmail.com" <<< $ssh_key
        fi
    done
}

git_bootstrap(){
    echo "git_bootstrap"
    exit

    ############
    # $COPY $DFH/dotfiles/git/gitconfig-global $HOME/.gitconfig-global
    # $COPY $DFH/dotfiles/git/gitconfig $HOME/.gitconfig
}

tmux_bootstrap(){
    echo "tmux_bootstrap"
    exit

    #############
    # $COPY $DFH/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
}

zsh_bootstrap(){
    echo "zsh_bootstrap"
    exit

    ####################
    ZSH_BIN_PATH=`which zsh`
    if [ -z "$ZSH_BIN_PATH" ];
    then
        echo "ZSH is not installed. Installing it ..."
        if [[ $OS == 'Linux' ]]; then
            echo "installing for linux"
        elif [[ `uname` == 'Darwin' ]]; then
            echo "installing for macos"
        fi
    else
        ZSH_VERSION=`zsh --version`
        echo -e "ZSH is already installed: $GREEN$ZSH_VERSION$WHITE"
    fi


    # $COPY $DFH/dotfiles/zsh/zshrc $HOME/.zshrc
    #------------- Install zsh, make it default shell
    # if [[ -d ~/.oh-my-zsh/ ]]; then
    #     echo "Oh-My -Zsh exists"
    # else
    #     # Clone oh-my-zsh and change URLs from HTTPS to SSH
    #     git clone https://github.com/IlyaKisil/oh-my-zsh.git ~/.oh-my-zsh/
    #     cd ~/.oh-my-zsh/
    #     git remote set-url origin git@IlyaKisil.github.com:IlyaKisil/oh-my-zsh.git
    #     cd ~/
    #
    #     # Git clone/install/delete powerline fonts for ``agnoster`` theme
    #     git clone https://github.com/powerline/fonts.git --depth=1
    #     cd fonts
    #     ./install.sh
    #     cd ..
    #     rm -rf fonts
    # fi
}




##########################################
###--------        Main        --------###
##########################################


# Change URLs from HTTPS to SSH in order to use an appropriate ssh key
# git remote set-url origin git@IlyaKisil.github.com:IlyaKisil/config-lib.git

# if [ $COPY_FILES -eq 1 ]
# then
# 	printf "\nConfiguration files will be ${GREEN}copied$WHITE.\n"
# 	COPY="cp -r"
# else
# 	printf "\n** Configuration files will be ${GREEN}symbolic links$WHITE.\n"
# 	COPY="ln -sf"
# fi
#
# if [ $BACKUP -eq 1 ]
# then
# 	printf "\nCreating a backup of the current configuration files in $GREEN$BACKUP_DIR$WHITE.\n"
#     # backup_config
# fi





# backup_config
# clean_config
# git_bootstrap
# tmux_bootstrap
# ssh_bootstrap
# zsh_bootstrap


# -----------------------------------
