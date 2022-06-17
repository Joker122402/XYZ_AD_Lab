# 03 - Automating JSON Schema Generation

1. Created `random_schema.json` to generate randomly assembled user and group data in json format to be used with `gen_ad.ps1`
    - Created `/data` to store lists of first/lastnames, passwords, and group names

2. Modified `gen_ad.ps1` to remove password policy to allow for weak pssowrds
    - Not fully successful. Accounts are created but disabled cuz of password policy