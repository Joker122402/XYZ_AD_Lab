# 01 - Install Domain Controller


1. Use `sconfig` to:
    - Change Hostname
    - Change IP Address to Static
    - Change DNS Server to be Ourself

2. Install AD Domain Services

```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagmentTools
```

3. Create AD Forest
```shell
import-Module ADDSDeployment
```
```shell
install-ADDSForest
```

4. Update DNS Server Address After Install (Without SConfig)
    - Determine which interface is being used:
    ```shell
    Get-NetIPAddress -IPAddress 10.0.2.155
    ```

    - Updated DNS Server Address:
    ```shell
    Set-DnsClientServerAddress -InterfaceIndex 5 -ServerAddresses 10.0.2.155
    ```

5. Join WS-01 to Domain via PS
```shell
Add-Computer -DomainName xyz.com -Credential xyz\Administrator -Force -Restart
```