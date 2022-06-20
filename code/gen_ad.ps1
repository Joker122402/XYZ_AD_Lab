param( 
    [Parameter(Mandatory=$true)] $JSONschema,
    [switch] $revert
    )

function CreateADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject)
    $name = $groupObject.name

    New-ADGroup -name $name -GroupScope Global
}

function RemoveADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject)
    $name = $groupObject.name

    Remove-ADGroup -Identity $name -Confirm:$false
}

function CreateADUser(){
    param( [Parameter(Mandatory=$true)] $userObject)

    # Pull name from JSON Object
    $name = $userObject.name
    $password = $userObject.password

    # Generate a "First Initial, Last Name" structure for username
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username
    $principalname = $username
    
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount


    # Add user to its groups
    foreach ($group_name in $userObject.groups) {

        try {
            Get-ADGroup -Identity $group_name
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "User $name not added to group $group_name beacuse group does not exist"
        }
    }
}

function RemoveADUser(){
    param( [Parameter(Mandatory=$true)] $userObject)
    $name = $userObject.name
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username

    Remove-ADUser -Identity $samAccountName -Confirm:$false
}

function WeakenPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content c:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File c:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    Remove-Item -force c:\Windows\Tasks\secpol.cfg -confirm:$false
}

function StrengthenPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content c:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File c:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    Remove-Item -force c:\Windows\Tasks\secpol.cfg -confirm:$false
}


# Ingest schema
$json = (Get-Content $JSONschema | ConvertFrom-Json)

# Set Global Domain
$Global:Domain = $json.domain

if (-not $revert){
    # Weaken Password Policy
    WeakenPasswordPolicy

    # Create Groups
    foreach ($group in $json.groups) {
        CreateADGroup $group
    }

    # Create Users
    foreach ($user in $json.users) {
        CreateADUser $user
    }
} else {
    StrengthenPasswordPolicy

    # Remove Users
    foreach ($user in $json.users) {
        RemoveADUser $user
    }

    # Remove groups
    foreach ($group in $json.groups) {
        RemoveADGroup $group
    }
}