param( [Parameter(Mandatory=$true)] $JSONschema)

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

function RemoveADUser(){
    param( [Parameter(Mandatory=$true)] $userObject)
    $name = $userObject.name

    Remove-ADUser -Identity $name -Confirm:$false
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
    
   #  try {
        # Create the AD-User Object
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount
   #  }
   #  catch [ ADPasswordComplexityException ]
   #  { 
   #      Write-Warning "User $name not created because Password does not meet complexity requirments"
   #      RemoveADUser $username
   # }


    # Add user to its groups
    foreach ($group_name in $userObject.groups) {

        try {
            Get-ADGroup -Identity $group_name
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "User $name not added to group $group_name beacuse group does not exist"
            RemoveADGroup $group_name
        }
    }
}

function WeakenPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content c:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File c:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    Remove-Item -force c:\Windows\Tasks\secpol.cfg -confirm:$false
}


# Weaken Password Policy
WeakenPasswordPolicy

# Ingest schema
$json = (Get-Content $JSONschema | ConvertFrom-Json)

# Set Global Domain
$Global:Domain = $json.domain

# Create Groups
foreach ($group in $json.groups) {
    CreateADGroup $group
}

# Create Users
foreach ($user in $json.users) {
    CreateADUser $user
}