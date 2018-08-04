# do-ddns
Use DigitalOcean DNS as an alternative to DynDNS, No-IP etc.

This simple shell script updates an IP for a given subdomain on your DigitalOcean's DNS to the current IP from where it's executed and notifies you on Telegram of the update.

I myself have a group on Telegram with bots for each of my private servers. For my home servers in Berlin and São Paulo the respective bots post there whenever there's an update for the dynamic IP on my home connections.

I use `telegram-send` (https://pypi.org/project/telegram-send/) for posting a message to the group on Telegram.

For talking to DigitalOcean's API I use `doctl` (https://github.com/digitalocean/doctl).

I also used `dig` to query the IP directly from DigitalOcean's nameserver. On Debian based systems you can get `dig` by installing the package `dnsutils`.

I won't go through the steps of setting these up, but it's pretty straighforward. Tutorials can be found on each project's repositories.

To use the script, simply call it passing as argument the FQDN of the subdomain you want to update the IP for:

```
ricardo@homeserver ~ $ /usr/local/bin/do-ddns.sh subdomain.example.org
ricardo@homeserver ~ $
```

I have it running on my crontab every 3 minutes.

Sample output on Telegram:

![Alt](/do-ddns_sample.png "Sample output")
