# XMPP Web Registration

![pic](https://i.imgur.com/FBH8q7S.png)

A simple web-based registration system for a Prosody XMPP server.
It allows users to create XMPP accounts via a web form with:

* Username & domain selection
* Password & confirmation
* CAPTCHA verification to prevent bots

Backend implemented in Perl using:

* `CGI` for handling web requests
* `Authen::Captcha` for CAPTCHA generation & validation
* `Expect` to automate `prosodyctl adduser`

Includes front-end HTML/CSS pages for registration and error handling.

## Requirements

* Prosody XMPP server
* Perl modules: `CGI`, `Authen::Captcha`, `Expect`
* `doas` for privilege escalation (or `sudo`)

## doas configuration

Add the following line to `doas.conf` to allow the web server user to create XMPP
accounts without a password:

```
permit nopass www as root cmd /usr/local/bin/prosodyctl
```

## Usage

1. Configure `config.pl` with valid domains.
2. Serve the HTML/CSS files and CGI scripts via a web server.
3. Users can register XMPP accounts securely through the web interface.