home
====
Home directory setup on any computer to avoid manually 
doing it every time my company moves to a new data center.

gpg-agent --daemon

[ikaprizkina@iad-stg-devchef101 home]$ gpg-agent --daemon
GPG_AGENT_INFO=/tmp/gpg-ctBb2G/S.gpg-agent:13858:1; export GPG_AGENT_INFO;
[ikaprizkina@iad-stg-devchef101 home]$ set | grep GPG_AGENT_INFO
[ikaprizkina@iad-stg-devchef101 home]$ GPG_AGENT_INFO=/tmp/gpg-ctBb2G/S.gpg-agent:13858:1; export GPG_AGENT_INFO;
[ikaprizkina@iad-stg-devchef101 home]$ gpg --gen-key

