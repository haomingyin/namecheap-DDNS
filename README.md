# Namecheap-DDNS
A Bash script to update DNS record on [Namecheap](https://www.namecheap.com/).

## Preparation

### Set Up A Record
Before you run the script, please make sure that you have set up your Namecheap DDNS `A record`. Instruction can be found [here](https://www.namecheap.com/support/knowledgebase/article.aspx/36/11/how-do-i-start-using-dynamic-dns).

### How To Get DDNS Password
Also make sure you have the DDNS password with you. If you haven't, please follow the steps below.

First, login to your Namecheap panel, then go to `Domain List` >> click `Manage` next to the domain >> `Advanced DNS` tab >> Scroll to `Dynamic DNS` section. If it is not enabled, enable it to get the password.

## Get Started

### Things You Should Know
Your record will not hit the Namecheap API if the given IP is identical to the remote DDNS record. However, if you still want to force push the already existed record for testing purpose, you could pass `-f` or `--force` argument.

```bash
$ ./updateDNS.sh --force
```

By doing this, the script will send a request even if the DDNS record needs not to be updated. It is not recommended to use in production mode.

### Run With Prompt
1. Clone the repository to you local machine
2. Change directory into the cloned repository
3. Run updateDNS.sh script
    ```bash 
    $ ./updateDNS.sh
    ```
4. Following prompt, enter required parameters

### Run With Automated Script
Just export required environment variables, and run `updateDNS.sh` script.

#### Required Environment Variables

| Env Variable | Comment | Example |
|:---:|---|---|
|HOST|The "[A + Dynamic DNS record](https://www.namecheap.com/support/knowledgebase/article.aspx/43/11/how-do-i-set-up-a-host-for-dynamic-dns)" to be updated|`@`, `www`|
|DOMAIN_NAME|The domain name | `haomingin.com`|
|PASSWORD| Namecheap DDNS password  | `sample-password` |
|IP|*[Optional]* If not given, the IP address that hits namecheap API will be used    | `127.0.0.1` |

#### How To Set Environment Variables
You can use `export` to set environment variables in your current terminal session, and you can reuse them. For example,

```bash
$ export HOST=www
$ export DOMAIN_NAME=haomingyin.com
$ export PASSWORD=sample-password
$ ./updateDNS.sh
```
Or simply,

```bash
$ HOST=www DOMAIN_NAME=haomingyin.com PASSWORD=smaple-password ./updateDNS.sh
```

## Reference

### Official Instruction
Namecheap official [guideline](https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-do-i-use-a-browser-to-dynamically-update-the-hosts-ip) of setting up DDNS using your browser.

### Sample Response
* Successful response
```xml
<?xml version="1.0"?>
<interface-response>
    <Command>SETDNSHOST</Command>
    <Language>eng</Language>
    <IP>127.0.0.1</IP>
    <ErrCount>0</ErrCount>
    <ResponseCount>0</ResponseCount>
    <Done>true</Done>
    <debug>
        <![CDATA[]]>
    </debug>
</interface-response>
```
* Error response
```xml
<?xml version="1.0"?>
<interface-response>
    <Command>SETDNSHOST</Command>
    <Language>eng</Language>
    <ErrCount>1</ErrCount>
    <errors>
        <Err1>No Records updated. A record not Found;</Err1>
    </errors>
    <ResponseCount>1</ResponseCount>
    <responses>
        <response>
            <ResponseNumber>380091</ResponseNumber>
            <ResponseString>No updates; A record not Found;</ResponseString>
        </response>
    </responses>
    <Done>true</Done>
    <debug>
        <![CDATA[]]>
    </debug>
</interface-response>
```
