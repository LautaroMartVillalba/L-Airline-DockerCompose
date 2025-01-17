### Vault configuration
1. Execute `docker-compose up vault-custom -d` to initialize the Vault container. 
2. Execute `docker-compose exec vault-custom` to access the vualt-custom container.
3. Execute `vault operator init -key-shares=3 -key-threshold=3` to initialize Vault . You will recieve a message like this:
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
This means that Vault has Initialized. You must to securely save the values above (three unseal keys and one root key) in a **secure place**.

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
Repleace UNSEAL1, UNSEAL2 and UNSEAL3 with the unseal keys retrieved from Vault . Save the file and proceed.

5. Reset Vault container with `docker-compose down` and `docker-compose up vault-custom -d` another one time. Enter to the container with `docker-compose exec vault-custom sh` and execute `vault status`. If "sealed" is false, the script work correctly.
6. Log in to Vault with `vault login xyzxyz` (xyzxyz it's the "Initial Root Token" retrieved when you initialized Vault)
7. Create the secrets path with `vault secrets enable -path=kv/database kv-v2` to create a path where the secrets (key-value instances) will be stored. `kv/database` is the complet path, and `kv-v2` determinates storage version.
8. Now you can save the credentials. Use the command `vault kv put kv/database email.address=bossamartindev@gmail.com email.password="lbfy jqgr epee ghaq" jwt.secret=secretTokenWithMoreThan32StringLenght spring.datasource.password=password spring.datasource.username=username`
 - email.address: testing mail, only for testing and divulgation.
 - email.password: corresponding password to email.address.
 - jwt.secret: secret key to use in JWT Algorithm hashing.
 - spring.datasource.password: set the DataBase password
 - spring.datasource.password: set the DataBase Root User
9. Now you can type `exit` to exit from vault-custom container and execute `docker-compose down` to close vault-custom container. 
### Environment variables
To execute the docker-compose images, you need to set some environment variables. That's are three key-value variables that you need.
1. Create in the same folder where docker-compose.yml is a .env file. You can use shell typing `touch example.env`.
2. Create the environment variables. Get in the .env file typing `nano example.env`, you have to set the following values:
```env
POSTGRES_USER=XXXXXX
POSTGRES_PASSWORD=YYYYYYY
TOKEN=xyzxyz
```
POSTGRES_USER and POSTGRES_PASSWORD it's a new Root Role in Postgres image, you can use the values that you want.
TOKEN is the same String that Vault retrieved when you did `vault init operator...`, it's the Initial Root Token.

3. You have all you need to initialize docker-compose file. Execute `docker-compose up -d` (if you want to see logs in real time, remove `-d` parameter). Nice! You can use L-Airline API

If you have problems with your configuration, or have some recommendations, communicate with me to lautaromartinvillalba@gmail.com.
