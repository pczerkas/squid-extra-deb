# Squid with extra refresh_pattern options

Build scripts for https://launchpad.net/~pczerkas/+archive/ubuntu/squid-extra

- re-added ignore-must-revalidate and ignore-auth options in refresh_pattern config
- fixed ignore-private option in refresh_pattern config for better cacheability

## PPA usage

```
sudo add-apt-repository ppa:pczerkas/squid-extra
sudo apt update

sudo apt-get -y install squid-openssl=6.10-1ubuntu7+ssl+extra # for Ubuntu Jammy (22.04)
// or
sudo apt-get -y install squid-openssl=6.10-1ubuntu10+ssl+extra # for Ubuntu Focal (20.04)
```
