#!/bin/bash
export GIT_EDITOR=vim
export EDITOR=vim

alias dg="dig axfr @10.5.32.21 ihr" 
alias dgq="dig axfr @10.5.32.21 qa.cloud.ihr" 
alias dgp="dig axfr @10.5.32.21 prod.cloud.ihr" 
alias dgc="dig axfr @10.5.32.21 cloud.ihr" 

alias vi=vim
alias elastic1="ssh ec2-user@107.20.168.221"
alias elastic2="ssh ec2-user@107.22.185.130"
alias elastic3="ssh ec2-user@184.73.182.99"
alias elastic4="ssh ec2-user@23.21.246.125"
alias elastic5="ssh ec2-user@54.243.202.96"

PS1="[\u@\h \W]\$ "

export PATH=.:/opt/chef/bin:$PATH

umask 0022
