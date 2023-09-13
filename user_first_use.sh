#!/usr/bin/env bash

ansible_env_token=$ANSIBLE_GALAXY_SERVER_TOKEN
email_regex="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$"
number_regex="^[0-9]+$"
min_input_value=1
max_input_value=3

black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`

function print_welcome_script()
{
    echo "${magenta}Welcome to Matt Clark's WSL Development environment."
    echo "Please follow prompts for initial setup to help get you going."
    echo ""
}

function get_git_user_name()
{
    echo "${blue}Please enter your name as you would like for git user.name. ${yellow}Example: John Doe"
    read -r gitname
    echo "${blue}"
}

function get_git_user_email()
{
    echo "${blue}Please enter your name as you would like for git user.email. ${yellow}Example: John.Doe@something.com"
    read -r gitemail
    while (! [[ $gitemail =~ $email_regex ]])
    do
        echo "${red}Invalid email address. Please enter valid email address for git. ${yellow}Example: John.Doe@something.com"
        read -r gitemail
    done
    echo "${blue}"
}

function get_git_use_ssh()
{
    echo "${blue}Do you use ssh keys for remote git repos? If yes will copy current ssh keys to the wsl environment and update provided repos to use ssh."
    echo -n "${yellow}y/n: "
    read -r gitusessh
    while [ $gitusessh != 'y' ] && [ $gitusessh != 'n' ]
    do
        echo "${red}Must y or n for an answer to do you use ssh keys for remote git repos?"
        echo -n "${yellow}y/n: "
        read -r gitusessh
    done
    echo "${blue}"
}

function display_answers()
{
    clear
    echo ""
    echo "${magenta}Provided Answers:"
    echo ""
    echo "${blue}1. git user.name:${yellow} $gitname"
    echo "${blue}2. git user.email:${yellow} $gitemail"
    echo "${blue}3. git use ssh?${yellow} $gitusessh"
    echo "${cyan}Note: Updating ansible token will automatically set have token to y"
    echo ""
}

function get_proceed_value()
{
    echo "${cyan}Are you good to proceed or need to update any answers: Press # to update corresponding field; otherwise press y to go ahead or n to cancel.${yellow}"
    echo -n "${blue}y/n/#:${yellow} "
    read -r good_to_proceed
    while (([ "$good_to_proceed" != 'y' ] && [ "$good_to_proceed" != 'n' ]) && ! [[ $good_to_proceed =~ $number_regex ]]) || ([[ $good_to_proceed =~ $number_regex ]] && ([ "$good_to_proceed" -lt $min_input_value ] || [ "$good_to_proceed" -gt $max_input_value ]))
    do
        echo "${red}Must y or n or valid # (Between $min_input_value and $max_input_value) for an answer"
        echo -n "${blue}y/n/#:${yellow} "
        read -r good_to_proceed
    done
}

function handle_proceed_value()
{
    if [ "$good_to_proceed" == 'n' ]
    then
        echo "${red}You chose to cancel; exiting the user first use script."
        exit 0
    elif [ "$good_to_proceed" == 'y' ]
    then
        echo "${green}You chose to proceed; performing automation tasks now..."
    else

        if [ "$good_to_proceed" == 1 ]
        then
            echo "${yellow}You chose #1 to revise git user.name"
            get_git_user_name
        elif [ "$good_to_proceed" == 2 ]
        then
            echo "${yellow}You chose #2 to revise git user.email"
            get_git_user_email
        elif [ "$good_to_proceed" == 3 ]
        then
            echo "${yellow}You chose #3 to revise if you use git ssh keys."
            get_git_use_ssh
        else
            echo "${red}Unable to proceed due to unknown circumstance."
            exit 0
        fi
        finalize_input
    fi
}

function finalize_input()
{
    display_answers
    get_proceed_value
    handle_proceed_value
}

function run_automation_playbook()
{
    ansible-playbook patch_user.yml --extra-vars \
        "ev_git_username='$gitname' \
        ev_fix_ansible_navigator=y \
        ev_git_email=$gitemail \
        ev_git_use_ssh=$gitusessh \
        ev_vscode_settings_refresh=y \
        ev_vscode_extensions_refresh=y" \
        --inventory inventory -vvv
}

print_welcome_script
get_git_user_name
get_git_user_email
get_git_use_ssh
finalize_input
run_automation_playbook
echo "${green}Finished setting up user; enjoy Windows Subsytem for Linux (WSL)!"

#Temp Fix for ansible-navigator path future images when released could have this removed.
source ~/.profile
