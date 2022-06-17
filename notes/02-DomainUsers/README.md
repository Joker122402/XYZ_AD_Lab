# 02 - Starting User Creation Automation

1. Created ad_schema.json
  - This will be the config file that will be used with out script
  - Defined users, Groups, domain etc...

2. Created gen_ad.ps1
  - This script will parse the json file and create an ad enviornment for us.
  - Created `CreateADGroup` and `CreateADUser` functions
  - Tested Script to ensure it is working up to this point

Script and schema can be found in the code folder. 