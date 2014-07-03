#!/bin/bash
export GIT_EDITOR=vim
export EDITOR=vim

alias dg="dig axfr @10.5.32.21 ihr" 
alias vi=vim
alias elastic1="ssh ec2-user@107.20.168.221"
alias elastic2="ssh ec2-user@107.22.185.130"
alias elastic3="ssh ec2-user@184.73.182.99"

PS1="[\u@\h \W]\$ "

export PATH=.:$PATH

umask 0022
