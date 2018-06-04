#############################################################################
### General collection of aliases. Copy and paste to the local zshrc file ###
### NOTE: some of them might be outdated and wrong                        ###
#############################################################################




############### GENERAL ###############
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    alias bp='source ~/.bashrc'
    alias ls='ls --color=auto -la'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias bp='source ~/.bash_profile'
    alias ls='ls -la'
    alias show='defaults write com.apple.finder AppleShowAllFiles YES;killall Finder /System/Library/CoreServices/Finder.app'
    alias hide='defaults write com.apple.finder AppleShowAllFiles NO;killall Finder /System/Library/CoreServices/Finder.app'
fi
alias ..='cd ..'
alias clc='clear'
alias add='git add --all;git status'
alias grep='grep --color=auto'


############### CD TO SPECIFIC DIRECTORIES ###############
alias gh='cd ~/GitHub'
alias gl='cd ~/GitLab'


############### REMOTE CONTROL ###############
# ssh to my EEE machine
alias eee='ssh eee_ubuntu'
# ssh to my EEE_MAC_mini machine
alias eeem='ssh eee_mac_mini'
# ssh to instance-1 on the google cloud platform
alias gc='gcloud compute ssh --zone=us-west1-b instance-1'


############### MOUNT DEVICES ###############
MOUNT_POINT=~/Mount
if [[ "$USER" == "ik1614" ]]; then
    # mount EEE_MAC_mini machine home directory
    alias ikm='sshfs ilia_eee_mac@dyn125-229.ee.ic.ac.uk:/Users/ilia_eee_mac/ $MOUNT_POINT/1-EEE-ilia_eee_mac'
    alias uikm='sudo umount $MOUNT_POINT/1-EEE-ilia_eee_mac'
    # mount ownCloud server home directory
    alias sel='sshfs sel@155.198.125.147:/home/sel/ $MOUNT_POINT/2-sel-home-CSP-Mandic'
    alias usel='sudo umount $MOUNT_POINT/2-sel-home-CSP-Mandic'
    # mount ownCloud server home directory
    alias own='sshfs sel@155.198.125.147:/var/www/owncloud/ $MOUNT_POINT/3-ownCloud-CSP-Mandic'
    alias uown='sudo umount $MOUNT_POINT/3-ownCloud-CSP-Mandic'
elif [[ "$USER" == "ilia_eee_mac" ]]; then
    # mount EEE (ubuntu) machine home directory
    alias ik='sshfs ik1614@155.198.125.35:/home/ik1614/ $MOUNT_POINT/1-EEE-ik1614 -ovolname='1-EEE-ik1614''
    alias uik='umount $MOUNT_POINT/1-EEE-ik1614'
elif [[ "$USER" == "ILIA" ]]; then
    # mount EEE (ubuntu) machine home directory
    alias ik='sshfs ik1614@155.198.125.35:/home/ik1614/ $MOUNT_POINT/1-EEE-ik1614 -ovolname='1-EEE-ik1614''
    alias uik='umount $MOUNT_POINT/1-EEE-ik1614'
    # mount EEE_MAC_mini machine home directory
    alias ikm='sshfs ilia_eee_mac@dyn125-229.ee.ic.ac.uk:/Users/ilia_eee_mac/ $MOUNT_POINT/1-EEE-ilia_eee_mac -ovolname='1-EEE-ilia_eee_mac''
    alias uikm='umount $MOUNT_POINT/1-EEE-ilia_eee_mac'
fi


############### MATLAB ###############
# if option -nojvm is included then parpool will produce error
# alias mat='matlab -nojvm -nodisplay -nosplash'
# launch matlab WITHOUT plot function
alias mat='matlab -nodisplay -nosplash'


############### PYTHON ###############
alias python="python3"
alias anaco='anaconda-navigator'
alias sa='source activate'
alias sd='source deactivate'
alias jn='jupyter notebook'
alias jl='source deactivate;source activate py36;jupyter lab'
