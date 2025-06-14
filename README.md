## Aclaration

This is a tutorial to learn how to set the necessary features to the project.

# Vault configuration
1. Execute `docker-compose up vault-custom -d` to initialize the Vault container.
2. Execute `docker-compose exec vault-custom sh` to access the vault-custom container.
3. Execute `vault operator init -key-shares=3 -key-threshold=3` to initialize Vault. You will receive a message like this:
```
Unseal Key 1: xxxxxx
Unseal Key 2: yyyyyy
Unseal Key 3: zzzzzz

Initial Root Token: xyzxyz

Vault initialized with 3 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 3 keys to
reconstruct the root key, Vault will remain permanently sealed!
```
This means that Vault has Initialized. You must securely save the values above (three unseal keys and one root key) in a **secure place**.

4. Go to /vault/unseal.sh archive and open it. It contains:
```
#!/bin/sh
echo "Waiting to Vault..."

until curl -s http://vault-custom:8200/v1/sys/health | grep -q '"sealed":true'; do
  echo "Vault not ready yet..."
  sleep 2
done

echo "Unsealing Vault"

vault operator unseal UNSEAL1
vault operator unseal UNSEAL2
vault operator unseal UNSEAL3

echo "Vault unsealed!"
``` 
Replace UNSEAL1, UNSEAL2 and UNSEAL3 with the unsealed keys retrieved from Vault. Save the file and proceed.

5. Reset Vault container with `docker-compose down` and `docker-compose up vault-custom -d` another one time. Enter to the container with `docker-compose exec vault-custom sh` and execute `vault status`. If "sealed" is false, the script works correctly.
6. Log in to Vault with `vault login xyzxyz` (xyzxyz it's the "Initial Root Token" retrieved when you initialized Vault)
7. Create the secret path with `vault secrets enable -path=kv/database kv-v2` to create a path where the secrets (key-value instances) will be stored. `kv/database` is the complet path, and `kv-v2` determinates a storage version.
8. Now you can save the credentials. Use the command `vault kv put kv/database email.address=bossamartindev@gmail.com email.password="lbfy jqgr epee ghaq" jwt.secret=secretTokenWithMoreThan32StringLenght spring.datasource.password=password spring.datasource.username=username spring.neo4j.authentication.username=neo4j spring.neo4j.authentication.password=password`
- **email.address**: testing mail, only for testing and divulgation.
- **email.password**: corresponding password to email.address.
- **jwt.secret**: secret key to use in JWT Algorithm hashing.
- **spring.datasource.password**: set the DataBase password
- **spring.datasource.password**: set the DataBase Root User
- **spring.neo4j.authentication.username**: set the Default username to the Neo4j database.
- **spring.neo4j.authentication.password**: set password to Default Neo4j User.
### Vault configuration it's ready. You can execute `exit` to exit from vault container, and stop the container with `docker-compose down`.
# Environment variables
To execute the docker-compose images, you need to set some environment variables. These are five key-value variables that you need.
credentials.env:
```env
POSTGRES_USER=
POSTGRES_PASSWORD=
TOKEN=
NEO4JDB=
NEO4JPASS=
```
POSTGRES_USER, POSTGRES_PASSWORD, NEO4JDB and NEO4JPASS are customizable environment variables; they will make the root users for the databases.
TOKEN is the same String that Vault retrieved when you did `vault init operator...`, it's the Initial Root Token.
### That's all. Environment variables are ready!

# DataBase BackUp Configuration
1. Initialize the database container with `docker-compose --env-file credentials.env up postgres neo4j`.
2. Access the database container with `docker-compose exec postgres sh`.
3. Verify the cron status typing `service cron status`, if cron is not running type `service cron start`.
4. Execute `crontab -e`. You will see something like that:
```
# Edit this file to introduce tasks to be run by cron.                                                                                                      
#                                                                                                                                                           
# Each task to run has to be defined through a single line                                                                                                  
# indicating with different fields when the task will be run                                                                                                
# and what command to run for the task                                                                                                                      
#                                                                                                                                                           
# To define the time you can provide concrete values for                                                                                                    
# minute (m), hour (h), day of month (dom), month (mon),                                                                                                    
# and day of week (dow) or use '*' in these fields (for 'any').
#                                                                                                                                                           
# Notice that tasks will be started based on the cron's system                                                                                              
# daemon's notion of time and timezones.                                                                                                                    
#                                                                                                                                                           
# Output of the crontab jobs (including errors) is sent through                                                                                             
# email to the user the crontab file belongs to (unless redirected).                                                                                        
#
# For example, you can run a backup of all your user accounts                                                                                               
# at 5 a.m every week with:                                                                                                                                 
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/                                                                                                           
#                                                                                                                                                           
# For more information see the manual pages of crontab(5) and cron(8)                                                                                       
#                                                                                                                                                           
# m h  dom mon dow   command                                                                                                                                
                                                                                                                  
```
5. Go to file's bottom.
    1. Write in a new line `0 3 * * * /bin/sh /scripts/create-backup.sh`.
    2. In another new line write `10 3 * * * /bin/sh /scripts/clean-backup.sh`.

You have something like:
```
# Edit this file to introduce tasks to be run by cron.                                                                                                      
#                                                                                                                                                           
# Each task to run has to be defined through a single line                                                                                                  
# indicating with different fields when the task will be run                                                                                                
# and what command to run for the task                                                                                                                      
#                                                                                                                                                           
# To define the time you can provide concrete values for                                                                                                    
# minute (m), hour (h), day of month (dom), month (mon),                                                                                                    
# and day of week (dow) or use '*' in these fields (for 'any').
#                                                                                                                                                           
# Notice that tasks will be started based on the cron's system                                                                                              
# daemon's notion of time and timezones.                                                                                                                    
#                                                                                                                                                           
# Output of the crontab jobs (including errors) is sent through                                                                                             
# email to the user the crontab file belongs to (unless redirected).                                                                                        
#
# For example, you can run a backup of all your user accounts                                                                                               
# at 5 a.m every week with:                                                                                                                                 
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/                                                                                                           
#                                                                                                                                                           
# For more information see the manual pages of crontab(5) and cron(8)                                                                                       
#                                                                                                                                                           
# m h  dom mon dow   command
0 3 * * * /bin/sh /scripts/create-backup.sh
10 3 * * * /bin/sh /scripts/clean-backup.sh
```
6. Press CTRL + X and save changes before exiting the file.
7. Use the steps above to Neo4j container, changing step 2 from `docker-compose exec postgres sh` to `docker-compose exec neo4j sh`.

### Explaining
When you type `crontab -e` you access to a cron program file, where you set a schedule (minutes [0-59], hours [0-23], month day [1-31], month [1-12], week day [0-6, where 0 its sunday/1-7 where 7 its sunday]) and type the script to be executed in the specified schedule.

In this project, the `create-backup.sh` will execute at 03:00am, all days. And `clean-backup.sh` will execute at 03:10am all days.

### Database Backups configurated successfully!

### You have all you need to use this docker-compose file. Good Luck!

If you have problems with your configuration, or have some recommendations, communicate with me to lautaromartinvillalba@gmail.com.
