#!/bin/bash

####### SETUP PARAMETERS
currentTime="$(date "+%Y-%m-%d:%H:%M:%S")"

# Get system information
coreFileRhel="/etc/redhat-release"  
coreFileCent="/etc/centos-release"  
coreFileSuse="/etc/SuSE-release"  
coreFileUbuntu="/etc/lsb-release"

osPlatform=""           # OS platform,  red, centos, suse, ubuntu
osVersion=""            # OS version
osType=""               # legal value is workstation or server
pkgManagement=""

# All downloaded files will be put in this directory 
workPath="$HOME/.Moresoph-vim"

fname=$(basename $0)
scriptName=${fname%.*}
logFile="${HOME}/.${scriptName}.log"

repoUri="https://github.com/Moresoph/change-vim.git"
repoName="Moresoph-vim"

vundleUri="https://github.com/gmarik/vundle.git"
vundlePath="${workPath}/bundle/Vundle.vim"
vundleName="Vundle"

# Common necessary programs list
necessaryPro=("catags"\
              "vim-nox")
necessaryProNum=${#necessaryPro[@]}

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
# Step 1:
# Get system information
# populate the following vairables:
#    osPlatform
#    osVersion
#    osType
#    pkgManagement
#
function getSysInfo()
{
    systemType="$(uname  -a |grep -i Ubuntu 2>&1)"
    #Check Core file, checking sequence is rhel, cent, suse, ubuntu
    if [[ -f $coreFileCent ]]; then 
       osPlatform="$(cat $coreFileCent |cut -d ' ' -f1 |tr A-Z a-z  2>&1)"
       if [[ "$?" -ne "0" || "$osPlatform" -ne "centos" ]]; then
           myPrint "failed to get OS platform[Error]."
           exit 1
       fi
      
       # the contants of $coreFileCent may be 
       # "CentOS release 6.8 (Final)"
       # or "CentOS Linux release 7.2.1511 (Core)"
       # we need to adjust the field  
       num="$(cat $coreFileCent |wc -w 2>&1)"
       num=`expr $num - 1` 
       osVersion="$(cat $coreFileCent |cut -d ' ' -f$num |cut -d '.' -f1-2  2>&1)"
       if [[ "$?" -ne "0" || -z "$osVersion" ]]; then
           myPrint "failed to get OS version[Error]."
           exit 1
       fi

       osType="" # all cent is one type
      
    elif [[ -f $coreFileRhel ]]; then
       osPlatform="$(cat $coreFileRhel |cut -d ' ' -f1 |tr A-Z a-z  2>&1)"
       if [[ "$?" -ne "0" || "$osPlatform" -ne "red" ]]; then
           myPrint "failed to get OS platform[Error]."
           exit 1
       fi
       osVersion="$(cat $coreFileRhel |cut -d ' ' -f7  2>&1)"
       if [[ "$?" -ne "0" || -z "$osVersion" ]]; then
           myPrint "failed to get OS version[Error]."
           exit 1
       fi

       num="$(cat $coreFileRhel |grep -i server |wc -l 2>&1)"

       if [[ "$num" -ne "0" ]]; then
          osType="server"
       else
          osType="workstation"
       fi
 
    elif [[ -f $coreFileUbuntu  && -n "$systemType" ]]; then
       osPlatform="$(cat $coreFileUbuntu |grep DISTRIB_ID |cut -d '=' -f2 |tr A-Z a-z  2>&1)"
       if [[ "$?" -ne "0" || "$osPlatform" -ne "ubuntu" ]]; then
           myPrint "failed to get OS platform[Error]."
           exit 1
       fi
       osVersion="$(cat $coreFileUbuntu |grep DISTRIB_RELEASE |cut -d '=' -f2 |tr A-Z a-z  2>&1)" 
       if [[ "$?" -ne "0" || -z "${osVersion}" ]]; then
           myPrint "failed to get OS version[Error]."
           exit 1
       fi
    elif [[ -f  $coreFileSuse ]]; then
       myPrint "$scriptName does not support SUSE currently[Error]."
       exit 1
    fi 
   
    # Change all strings to be lower case
    osPlatform=`tr '[A-Z]' '[a-z]' <<<"$osPlatform"`
    osVersion=`tr '[A-Z]' '[a-z]' <<<"$osVersion"`
    osType=`tr '[A-Z]' '[a-z]' <<<"$osType"`

    # Set packagemanagement according to osPlatform
    if [[ "${osPlatform}" == "red" || "${osPlatform}" == "centos" || "${osPlatform}" == "suse" ]]; then
        pkgManagement="yum"
    elif [[ "${osPlatform}" == "ubuntu" ]]; then
        pkgManagement="apt"
    else
        pkgManagement="unknow"
    fi

    myPrintInfo "osPlatform=$osPlatform"
    myPrintInfo "osVersion=$osVersion"
    myPrintInfo "osType=$osType"    
    myPrintInfo "pkgManagement=${pkgManagement}"

}

#
# Step 2: Precheck to make sure this script can work well
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

    myPrintInfo "Everything is ok"
}

#
# Step 3: Do backup
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
    else
        myPrintInfo "$1 and $2 do not exist, don't need to backup"
    fi
}

#
# Step 4:Sync repository
#
function syncRepo()
{
    local repoPath="$1"    
    local repoUri="$2"
    local repoName="$3"
    myPrintInfo "Trying to clone or update ${repoName}"
    
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
# Step 5:Create symbolic links
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

# Step :Sync Vundle plug-in
#vundleUri="https://github.com/gmarik/vundle.git"
#vundlePath="$HOME/.vim/bundle/Vundle.vim"

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
function installPkg()
{
    programExists "$1"
    local ret="$?"
    if [[ ${ret} -ne 0 ]]; then 
        if [[ "${pkgManagement}" == "apt" ]]; then
            sudo apt-get -y install $1 
        elif [[ "${pkgManagement}" == "yum" ]]; then
            sudo yum -y install $1  
        else
            myPrintWarning "pkgManagement is ${pkgManagement}, Not supported"
        fi
    fi
}

function finalCheck()
{
    myPrintInfo "This phases will use sudo command to install some necessary programs,so ensure that your account has sudo permissions"
    local i=0
    for((i=0;i<necessaryProNum;i++)); do
        installPkg ${necessaryPro[$i]} 
    done

    if [[ "${osPlatform}" == "ubuntu" ]]; then
        installPkg "vim-nox"
    fi
    myPrintInfo "Use \"vim --version\" to check whether your vim supports \"lua\" ,if not ,google how to install vim with lua "  
}

# Used to call every step
currentstep=0
function promptStepInfo()
{   
    local str=$(echo $1 |cut -d " " -f1)
    local strenter="Step ${currentstep} : ${str}"
    myPrintEnterLeave "${strenter}"
    $1
    myPrintEnterLeave "Step ${currentstep} : Finished"
    ((currentstep++))
}

main()
{
    createLogFile         

    promptStepInfo "getSysInfo"

    promptStepInfo "preCheck"

    promptStepInfo "doBackUp "${HOME}/.vimrc"  "${HOME}/.vim""

    promptStepInfo "syncRepo  ${workPath} ${repoUri} ${repoName}"

    promptStepInfo "syncRepo ${vundlePath} ${vundleUri} "${vundleName}""

    promptStepInfo "createSymLinks "${workPath}" "${HOME}"" 

    promptStepInfo "setupWithVundle ${workPath}/.vimrc"

    promptStepInfo "finalCheck"
}
main "$@"

