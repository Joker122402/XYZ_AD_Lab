param( [Parameter(Mandatory=$true)] $JSONschema)

function CreateADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject)
    $name = $groupObject.name

    New-ADGroup -name $name -GroupScope Global
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
    
    # Create the AD-User Object
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