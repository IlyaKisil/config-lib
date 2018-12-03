#! /bin/bash

#########################################################################
#                                                                       #
#            |=====     ADJUSTING CNOME SHORTCUTS     =====|            #
#                                                                       #
#   For removing default/custom configurations use the following:       #
#   gsettings set org.gnome.desktop.wm.keybindings __COMMAND__ "['']"   #
#                                                                       #
#########################################################################


# Remove default binding


# Switching workspaces by Ctrl+arrow keys
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Ctrl>Down']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Ctrl>Up']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Ctrl>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Ctrl>Right']"


# Move window among workspaces by Ctrl+Alt+arrow keys
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Ctrl><Alt>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Ctrl><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Ctrl><Alt>Up']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Ctrl><Alt>Down']"

# Keyboard shortcuts for multimedia
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down '<Ctrl>F10'
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up '<Ctrl>F11'
