#!/usr/bin/env bash

help(){
echo "====================================================="
cat << EOF
usage: $0 [-h?] [-a]

BASIC OPTIONS:
   -h         Show this message
   -a         WIP: Automated setup (No backup, symlink etc)

By Ilya Kisil <ilyakisil@gmail.com>


EOF

show_outline

echo "====================================================="
}

##########################################
###----  Handy printing utilities  ----###
##########################################

RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BROWN="\033[0;33m"
WHITE="\033[0;0m"
function red(){
    printf "${RED}$1${WHITE}"
}
function green(){
    printf "${GREEN}$1${WHITE}"
}

function yellow(){
    printf "${RED}$1${WHITE}"
}

##########################################
###--------   Default values   --------###
##########################################


DATE=`date '+%Y-%m-%d'`
TIME=`date '+%H-%M-%S'`
OS=`uname`
CONFIG_HOME="$PWD"

declare -a CONFIG_FILES=(".gitconfig"
                         ".gitconfig-github"
                         ".gitignore-global"
                         ".zshrc"
                         ".zshrc-local"
                         ".tmux.conf"
                         ".tmux-local.conf"
                         ".nanorc"
                         ".ssh/config"
                         )
declare -a SSH_KEYS=("github_IlyaKisil"
                     "github_AnnaKisil"
                     "gitlab_ik1614"
                     "ik1614_eee"
                     "ik1614_doc"
                     "sap"
                     )

BACKUP_DIR="$HOME/.config_${DATE}_${TIME}"

AUTO=0

while getopts "ha" OPTION;
do
	case $OPTION in
		h|\?)
			help
            exit
			;;
        a)  AUTO=1
            ;;
	esac
done

#########################################
###--------     Functions     --------###
#########################################
show_outline(){
    echo "====================================================="
    echo "=====        Outline of what will happen        ====="
    echo "====================================================="
    echo ""

    echo "Preparation stage: "
    printf "\t 1. Make sure you have zsh and tmux installed. \n"
    printf "\t 2. Install them if you don't. \n"
    printf "\t 3. Make sure that zsh is your default shell. \n"
    printf "\t 4. Change it if it's not. \n\n"

    printf "Configuration stage: \n"
    printf "\t 1. Backup existing configuration (except symlinks) in: \n"
    printf "\t\t`green ${BACKUP_DIR}` \n"
    printf "\t 2. Clean existing configuration if exists. \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t`red $HOME/$name`\n"
    done
    printf "\t 3. Create new configuration for: \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t`green $HOME/$name`\n"
    done
    printf "\t 4. Create SSH keys if both private and public parts are missing: \n"
    for key_name in "${SSH_KEYS[@]}"
    do
        printf "\t\t`green $HOME/.ssh/$key_name`\n"
    done
    printf "\t 5. Change HTTPS to URL so to use appropriate SSH key. \n"

}

check_software(){
	printf "\nChecking to see if `green $1` is installed: "
	if ! [ -x "$(command -v $1)" ]; then
        echo -e "`red "not installed"`."
		install_software $1
	else
        soft_bin=`command -v $1`
		echo -e "`green ${soft_bin}`."
	fi
}

install_software(){
    printf "Would you like to install it? (y/n) "
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    if echo "$answer" | grep -iq "^y" ;then
        if [[ $OS == 'Linux' ]]; then
            if [ -x "$(command -v apt-get)" ]; then
                sudo apt-get install $1 -y
            else
                echo -e "`red Warning:` Not sure what your package manager is. Abort installation."
                echo -e "`red Warning:` Your configuration won't work as expected."
            fi
		elif [[ $OS == 'Darwin' ]]; then
            if [ -x "$(command -v brew)" ]; then
                brew install $1
            else
                echo -e "`red Warning:` Not sure what your package manager is. Abort installation."
                echo -e "`red Warning:` Your configuration won't work as expected."
            fi
		fi
    else
        echo -e "`red Warning:` Your configuration won't work as expected."
	fi
}

check_default_shell(){
    if [ -z "${SHELL##*zsh*}" ] ;then
        printf "Default shell is ${GREEN}already zsh${WHITE}.\n"
	else
        ZSH_BIN_PATH=`which zsh`
        CURRENT_SHELL=`which $SHELL`
		printf "\nDefault shell is `red ${CURRENT_SHELL}`. Trying to change to `green zsh`.\n"
        if [ -z "$ZSH_BIN_PATH" ]; then
            printf "\n`red WARNING:` You still don't have zsh. Your configuration won't work as expected."
        else
            echo "Changing default shell to zsh. Enter password: "

            if [[ $OS == 'Linux' ]]; then
                chsh -s ${ZSH_BIN_PATH}
            elif [[ $OS == 'Darwin' ]]; then
                echo "${ZSH_BIN_PATH}" | sudo tee -a /etc/shells > /dev/null
                chsh -s ${ZSH_BIN_PATH}
            fi
        fi
	fi
}

backup_config(){
    printf "\nBacking up an existing configuration.\n"

    README="$BACKUP_DIR/README.md"
    mkdir $BACKUP_DIR
    printf "Backup of configuration existed on $DATE at $TIME:\n\n" > $README
    for name in "${CONFIG_FILES[@]}"
    do
        config_file="$HOME/$name"
        if [[ -L $config_file ]]; then
            printf "$config_file is a symlink. No need to backup \n" >> $README
        elif [[ -f $config_file ]]; then
            cp -r $config_file $BACKUP_DIR
            printf "Copying $config_file \n" >> $README
        elif [[ -d $config_file ]]; then
            cp -r $config_file $BACKUP_DIR
            printf "Copying $config_file \n" >> $README
        else
            printf "Config file $config_file does not exist \n" >> $README
        fi
    done
}

clean_config(){
    printf "\nCleaning up an existing configuration.\n"

    for name in "${CONFIG_FILES[@]}"
    do
        config_file="$HOME/$name"
        if [[ -f $config_file ]]; then
            rm $config_file
        elif [[ -d $config_file ]]; then
            rm $config_file
        elif [[ -L $config_file ]]; then
            rm $config_file
        fi
    done

}

ssh_bootstrap(){
    printf "\nBootstrap of `green SSH` config files.\n"

    # setup ssh config
    SSH_CONFIG_HOME="$HOME/.ssh"
    if [[ ! -d $SSH_CONFIG_HOME ]]; then
        mkdir  $SSH_CONFIG_HOME
    fi
    $COPY $CONFIG_HOME/dotfiles/ssh/config $HOME/.ssh/config

    # create ssh keys only if both parts are missing
    local ssh_user
    local ssh_pc
    ssh_user=`whoami`
    ssh_pc=`uname -n`
    for name in "${SSH_KEYS[@]}"
    do
        ssh_key="$HOME/.ssh/$name"
        if [ ! -f $ssh_key ] && [ ! -f "${ssh_key}.pub" ]   ; then
            printf "\tSSH key `green $ssh_key` is missing. Creating one.\n"
            ssh-keygen -t rsa -b 4096 -C "${ssh_user}@${ssh_pc} ilyakisil@gmail.com" <<< $ssh_key
            printf "\tAdding this key to the ssh-agent.\n"
            ssh-add $ssh_key
        else
            printf "\tSSH key `red ${ssh_key}` exists. Creation is skipped.\n"
        fi
    done
}

git_bootstrap(){
    printf "\nBootstrap of `green GIT` config files.\n"

    $COPY $CONFIG_HOME/dotfiles/git/gitconfig $HOME/.gitconfig
    $COPY $CONFIG_HOME/dotfiles/git/gitconfig-github $HOME/.gitconfig-github
    $COPY $CONFIG_HOME/dotfiles/git/gitignore-global $HOME/.gitignore-global
}

tmux_bootstrap(){
    printf "\nBootstrap of `green TMUX` config files.\n"

    printf "\t 1) Creating `green ".tmux.conf"`\n"
    $COPY $CONFIG_HOME/dotfiles/tmux/tmux.conf $HOME/.tmux.conf

    printf "\t 2) Creating local configuration for tmux in `green ".tmux-local.conf"`\n"
    cp $CONFIG_HOME/dotfiles/tmux/tmux-local.conf $HOME/.tmux-local.conf


    # ------------- Check that Tmux Plugin Manager is installed
    printf "\t 3) Cloning `green "Tmux plugin manager"`\n"
    if [[ -d $HOME/.tmux/plugins/tpm/ ]]; then
        echo -e "\t Tmux Plugin Manager exists."
    else
        # Clone tmux plugin manager
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    fi
    echo -e "Press `green "prefix + I"` in tmux session to install plugins.\n"
}

zsh_bootstrap(){
    printf "\nBootstrap of `green ZSH` config files.\n"

    printf "\t 1) Cloning `green "oh-my-zsh"`\n"
    if [[ -d $HOME/.oh-my-zsh/ ]]; then
        echo -e "\t Oh-My-Zsh exists."
    else
        # Clone oh-my-zsh and change URLs from HTTPS to SSH
        git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh/

        # Git clone/install/delete powerline fonts for ``agnoster`` theme
        git clone https://github.com/powerline/fonts.git --depth=1
        cd fonts
        ./install.sh
        cd ..
        rm -rf fonts
    fi

    printf "\t 2) Creating `green ".zshrc"`\n"
    $COPY $CONFIG_HOME/dotfiles/zsh/zshrc $HOME/.zshrc

    printf "\t 3) Creating local configuration for the zsh in `green ".zshrc-local"`\n"
    $COPY $CONFIG_HOME/dotfiles/zsh/zshrc-local $HOME/.zshrc-local
    sed -i "s|__CONFIG_HOME__|$CONFIG_HOME|g" $HOME/.zshrc-local

}

nano_bootstrap(){
    printf "\nBootstrap of `green NANO` config files.\n"

    $COPY $CONFIG_HOME/dotfiles/nano/nanorc $HOME/.nanorc
}

change_https_to_url(){

    # Change URLs from HTTPS to SSH in order to use an appropriate ssh key
    cd $CONFIG_HOME
    printf "\nChanging HTTPS to URL for origin of `green config-lib.git`\n"
    echo $PWD
    git remote -v
    git remote set-url origin git@IlyaKisil.github.com:IlyaKisil/config-lib.git
    git remote -v
}


##########################################
###--------        Main        --------###
##########################################
show_outline

printf "\nLet's get started? (y/n) "
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
if echo "$answer" | grep -iq "^y" ;then
    echo -e "\nFingers crossed and start. `green ":-/"`"
else
    echo -e "\nQuitting, nothing was changed `red ":-("`\n"
    exit 0
fi

check_software zsh

check_software tmux

check_default_shell

backup_config

clean_config

printf "\nWould you like to bootstrap as symlinks as opposed to copying? (y/n) "
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
if echo "$answer" | grep -iq "^y" ;then
    printf "Configuration files will be `green "symbolic links"`.\n\n"
    COPY="ln -sf"
else
    printf "Configuration files will be `red copied`.\n\n"
    COPY="cp -r"
fi

git_bootstrap
zsh_bootstrap
ssh_bootstrap
tmux_bootstrap
nano_bootstrap

change_https_to_url

printf "\n=======================================\n"
printf "=== `green 'Profile configuration completed'` ===\n"
printf "=======================================\n\n"
