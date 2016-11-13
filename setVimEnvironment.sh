#!/bin/bash

####### SETUP PARAMETERS
currentTime="$(date "+%Y-%m-%d:%H:%M:%S")"

workPath="$HOME/.Moresoph-vim"

fname=$(basename $0)
scriptName=${fname%.*}
logFile="${HOME}/.${scriptName}.log"

repoUri="https://github.com/Moresoph/change-vim.git"
repoName="Moresoph-vim"

#
# Create log file
#
function createLogFile()
{
    if [[ ! -f "${logFile}" ]]; then
        touch "${logFile}"      
        local ret="$?"
        if [[ "${ret}" -ne "0" ]]; then
           echo "[Warning]: failed to create log file:${logFile}"  
        fi
    fi 

    echo "#### Begin ${scriptName} ####">>${logFile}
    echo ${currentTime} >> ${logFile}  
}

function myLog()
{
    echo $1 >> "${logFile}"
}

#
#Output the log or debug information
#
function myPrint()
{
     echo $1 |tee -a "${logFile}"
}
 
function myPrintWithColor()
{
    echo -e $1 
    echo $2 >> "${logFile}"
}

function myPrintEnterLeave()
{
    local str=$1
    echo "   "
    myPrint '******'"${str}"'*******'
    echo "   "
}

function myPrintInfo()
{
    local str=$1
    myPrintWithColor "\033[36m[Info]\033[0m : ${str}" "${str}"
}

function myPrintWarning()
{
    local str=$1
    myPrintWithColor "\033[33m[Warning]\033[0m : ${str}" "${str}"
}

function myPrintError()
{
    local str=$1
    myPrintWithColor "\033[31m[Error]\033[0m : ${str}" "${str}"
    exit 1
}


#
# Step 1: Precheck to make sure this script can work well
#         
function programExists()
{
    local ret="0"
    command -v $1 >/dev/null 2>&1 || { local ret="1"; }
    
    if [[ "${ret}" -ne 0 ]]; then
        return 1
    fi

    return 0
}

function programMustExists()
{
    programExists $1

    if [ "$?" -ne 0 ]; then
        myPrintError "You must have "$1" installed to continue" 
    fi
}

function preCheck()
{
    # check the Environment variable
    [ -z "${HOME}" ] && myPrintError "You must have your HOME environmental variable set to continue"  

    # check the necessary programs
    programMustExists vim
    programMustExists git
}

#
# Step 2: Do backup
#
function doBackUp()
{
    if [[ -e "$1" || -e "$2" ]]; then
        myPrintInfo "Attempting to back up your original vim configuration"
        local ret="0"
        for i in "$1" "$2"; do
            [[ -e "$i" ]] && mv -v "$i" "${i}.${currentTime}" || local ret="1" 
            [[ "${ret}" == "1" ]] && myPrintError "Failed back up ${1}" 
        done
        myPrintInfo "Your original vim configuration has been backed up"
    fi
}

#
# Step 3:Sync repository
#
function syncRepo()
{
    local repoPath="$1"    
    local repoUri="$2"
    local repoName="$3"
    myPrintInfo "Trying to update ${repoName}"
    
    if [[ ! -e "${repoPath}" ]]; then
        mkdir -p "${repoPath}"
        git clone "${repoUri}" "${repoPath}" 
        local ret="$?"
        [[ "${ret}" == "0" ]] && myPrintInfo "Successfully cloned ${repoName}"
    else
        cd "${repoPath}" && git pull
        local ret="$?"
        [[ "${ret}" == "0" ]] && myPrintInfo "Successfully updated ${repoName}"
    fi
}

#
# Step 4:Create symbolic links
#
function lnIf()
{
    if [[ -e "$1" ]]; then
        ln -sf "$1" "$2"
    fi
    local ret="$?"
    [[ "${ret}" != "0" ]] && myPrintError "Can't link ${1} ${2}"
}

function createSymLinks()
{
    local sourcePath="$1"
    local targetPath="$2"

    lnIf "${sourcePath}/.vimrc"  "${targetPath}/.vimrc" 
    lnIf "${sourcePath}/.vim"    "${targetPath}/.vim"
}

# Step 5:Sync Vundle plug-in
vundleUri="https://github.com/gmarik/vundle.git"
vundlePath="$HOME/.vim/bundle/Vundle.vim"

# Step 6:Using Vundle plug-in management
setupWithVundle()
{
    local system_shell="${SHELL}"
    export SHELL='/bin/sh'

    vim \
        -u "$1" \
        "+set nomore" \
        "+PluginInstall" \
        "+PluginClean" \
        "+qall"

    export SHELL="${system_shell}"

    myPrintInfo "Now updating/installing plugins using Vundle"
}

# Step 7:Make sure every plugins works well
function finalCheck()
{
    myPrintInfo "Enter finalCheck , not finished yet"
}

# Used to call every step
currentstep=1
function promptStepInfo()
{   
    ((currentstep++))
    local str=$(echo $1 |cut -d " " -f1)
    local strenter="Step ${currentstep} : ${str}"
    myPrintEnterLeave "${strenter}"
    $1
    myPrintEnterLeave "Step ${currentstep} : Finished"
}

main()
{
    createLogFile         

    promptStepInfo "preCheck"

    promptStepInfo "doBackUp "${HOME}/.vimrc"  "${HOME}/.vim""

    promptStepInfo "syncRepo  ${workPath} ${repoUri} ${repoName}"

    promptStepInfo "createSymLinks "${workPath}" "${HOME}"" 

    promptStepInfo "syncRepo ${vundlePath} ${vundleUri} "Vundle""

    promptStepInfo "setupWithVundle ${workPath}/.vimrc"

    promptStepInfo "finalCheck"
}
main "$@"
