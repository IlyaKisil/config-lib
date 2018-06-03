#! /bin/bash
clear

manual(){
echo "====================================================="
cat << EOF
usage: $0 [-h?] [-c]

BASIC OPTIONS:
   -h         Show this message
   -a         Automated setup (No backup, symlink etc)

By Ilya Kisil <ilyakisil@gmail.com>


EOF

show_outline

echo "====================================================="
}

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
    printf "\t\t${GREEN}${BACKUP_DIR}${WHITE} \n"
    printf "\t 2. Clean existing configuration if exists. \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t${RED}$HOME/$name$WHITE\n"
    done
    printf "\t 3. Create new configuration for: \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t$GREEN$HOME/$name$WHITE\n"
    done
    printf "\t 4. Create SSH keys if both private and public parts are missing: \n"
    for key_name in "${SSH_KEYS[@]}"
    do
        printf "\t\t$GREEN$HOME/.ssh/$key_name$WHITE\n"
    done
    printf "\t 5. Change HTTPS to URL so to use appropriate SSH key. \n"

}


##########################################
###--------   Default values   --------###
##########################################
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
BROWN="\033[0;33m"
WHITE="\033[0;0m"

DATE=`date '+%Y-%m-%d'`
TIME=`date '+%H-%M-%S'`
OS=`uname`
DFH="$PWD"

declare -a CONFIG_FILES=(".gitconfig"
                         ".gitignore-global"
                         ".zshrc"
                         ".zshrc-local"
                         ".tmux.conf"
                         ".ssh/config"
                         )
declare -a SSH_KEYS=("github_IlyaKisil"
                     "github_AnnaKisil"
                     "gitlab_ik1614"
                     "eee_ubuntu_ik1614"
                     "eee_mac_mini_ilia"
                     "owncloud_server"
                     "ik1614_doc"
                     )

BACKUP_DIR="$HOME/.config_${DATE}_${TIME}"

AUTO=0

while getopts "ha" OPTION;
do
	case $OPTION in
		h|\?)
			manual
            exit
			;;
        a)  AUTO=1
            ;;
	esac
done

#########################################
###--------     Functions     --------###
#########################################

check_software(){
	printf "\nChecking to see if ${GREEN}$1${WHITE} is installed: "
	if ! [ -x "$(command -v $1)" ]; then
        echo -e "${RED}not installed${WHITE}."
		install_software $1
	else
        soft_bin=`command -v $1`
		echo -e "${GREEN}${soft_bin}${WHITE}."
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
                echo -e "${RED}Warning:${WHITE} Not sure what your package manager is. Abort installation."
                echo -e "${RED}Warning:${WHITE} Your configuration won't work as expected."
            fi
		elif [[ $OS == 'Darwin' ]]; then
            if [ -x "$(command -v brew)" ]; then
                brew install $1
            else
                echo -e "${RED}Warning:${WHITE} Not sure what your package manager is. Abort installation."
                echo -e "${RED}Warning:${WHITE} Your configuration won't work as expected."
            fi
		fi
    else
        echo -e "${RED}Warning:${WHITE} Your configuration won't work as expected."
	fi
}

check_default_shell(){
    if [ -z "${SHELL##*zsh*}" ] ;then
        printf "Default shell is ${GREEN}already zsh${WHITE}.\n"
	else
        ZSH_BIN_PATH=`which zsh`
        CURRENT_SHELL=`which $SHELL`
		printf "\nDefault shell is ${RED}${CURRENT_SHELL}${WHITE}. Trying to change to ${GREEN}zsh${WHITE}.\n"
        if [ -z "$ZSH_BIN_PATH" ]; then
            printf "\n${RED}WARNING:${WHITE} You still don't have zsh. Your configuration won't work as expected."
        else
            echo "Changing default shell to zsh. Enter password: "

            if [[ $OS == 'Linux' ]]; then
                sudo chsh -s ${ZSH_BIN_PATH}
            elif [[ $OS == 'Darwin' ]]; then
                echo "${ZSH_BIN_PATH}" | sudo tee -a /etc/shells > /dev/null
                sudo chsh -s ${ZSH_BIN_PATH}
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
    printf "\nBootstrap of ${GREEN}SSH${WHITE} config files.\n"

    # setup ssh config
    SSH_CONFIG_HOME="$HOME/.ssh"
    if [[ ! -d $SSH_CONFIG_HOME ]]; then
        mkdir  $SSH_CONFIG_HOME
    fi
    $COPY $DFH/dotfiles/ssh/config $HOME/.ssh/config

    # create ssh keys only if both parts are missing
    for name in "${SSH_KEYS[@]}"
    do
        ssh_key="$HOME/.ssh/$name"
        if [ ! -f $ssh_key ] && [ ! -f "${ssh_key}.pub" ]   ; then
            printf "\tSSH key ${GREEN}$ssh_key${WHITE} is missing. Creating one.\n"
            ssh-keygen -t rsa -b 4096 -C "ilyakisil@gmail.com" <<< $ssh_key
        else
            printf "\tSSH key ${RED}${ssh_key}${WHITE} exists. Creation is skipped.\n"
        fi
    done
}

git_bootstrap(){
    printf "\nBootstrap of ${GREEN}GIT${WHITE} config files.\n"

    $COPY $DFH/dotfiles/git/gitconfig $HOME/.gitconfig
    $COPY $DFH/dotfiles/git/gitignore-global $HOME/.gitignore-global
}

tmux_bootstrap(){
    printf "\nBootstrap of ${GREEN}TMUX${WHITE} config files.\n"

    $COPY $DFH/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
}

zsh_bootstrap(){
    printf "\nBootstrap of ${GREEN}ZSH${WHITE} config files.\n"

    $COPY $DFH/dotfiles/zsh/zshrc $HOME/.zshrc
    printf "# Specific configurations for the local machine\n\n" >> $HOME/.zshrc-local
    printf "export LANG=en_US.UTF-8\n" >> $HOME/.zshrc-local

    # ------------- Install zsh, make it default shell
    if [[ -d ~/.oh-my-zsh/ ]]; then
        echo -e "Oh-My-Zsh exists. Consider to do ${GREEN}git pull${WHITE}."
    else
        # Clone oh-my-zsh and change URLs from HTTPS to SSH
        git clone https://github.com/IlyaKisil/oh-my-zsh.git ~/.oh-my-zsh/

        # Git clone/install/delete powerline fonts for ``agnoster`` theme
        git clone https://github.com/powerline/fonts.git --depth=1
        cd fonts
        ./install.sh
        cd ..
        rm -rf fonts
    fi
}

change_https_to_url(){

    # Change URLs from HTTPS to SSH in order to use an appropriate ssh key
    cd $DFH
    printf "\nChanging HTTPS to URL for origin of ${GREEN}config-lib.git${WHITE}\n"
    echo $PWD
    git remote -v
    git remote set-url origin git@IlyaKisil.github.com:IlyaKisil/config-lib.git
    git remote -v

    cd ~/.oh-my-zsh
    printf "\nChanging HTTPS to URL for origin of ${GREEN}oh-my-zsh.git${WHITE}\n"
    echo $PWD
    git remote -v
    git remote set-url origin git@IlyaKisil.github.com:IlyaKisil/oh-my-zsh.git
    git remote -v
    cd $DFH
}


##########################################
###--------        Main        --------###
##########################################
show_outline

printf "\nLet's get started? (y/n) "
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
if echo "$answer" | grep -iq "^y" ;then
    echo -e "\nFingers crossed and start. $GREEN:-/$WHITE"
else
    echo -e "\nQuitting, nothing was changed $RED:-($WHITE\n"
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
    printf "Configuration files will be ${GREEN}symbolic links$WHITE.\n\n"
    COPY="ln -sf"
else
    printf "Configuration files will be ${RED}copied$WHITE.\n\n"
    COPY="cp -r"
fi

git_bootstrap
zsh_bootstrap
ssh_bootstrap
tmux_bootstrap

change_https_to_url

printf "\n\n================================\n"
printf "=== ${GREEN}Configuration completed.${WHITE} ===\n"
printf "================================\n\n"
