# 01 - Install Domain Controller


1. Use `sconfig` to:
    - Change Hostname
    - Change IP Address to Static
    - Change DNS Server to be Ourself

2. Install AD Domain Services

```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagmentTools
```

