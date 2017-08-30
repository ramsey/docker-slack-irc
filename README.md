# benramsey/slack-irc Docker Image

[![Docker Automated Build](https://img.shields.io/docker/automated/benramsey/slack-irc.svg?style=flat-square)](https://hub.docker.com/r/benramsey/slack-irc/) [![MIT License](https://img.shields.io/github/license/ramsey/docker-slack-irc.svg?style=flat-square)](https://github.com/ramsey/docker-slack-irc/blob/master/LICENSE) [![Docker Build Status](https://img.shields.io/docker/build/benramsey/slack-irc.svg?style=flat-square)](https://hub.docker.com/r/benramsey/slack-irc/builds/)

This is a Docker image for [Martin Ek](https://github.com/ekmartin)'s [slack-irc bridge](https://github.com/ekmartin/slack-irc).

## Running

To run the slack-irc bridge, set up a configuration file named `config.json` and launch a slack-irc Docker container for that configuration:

``` bash
docker run -it -v /path/to/config-dir:/config benramsey/slack-irc
```

Alternately, you may give your configuration a different file name and pass the name as an argument, when launching the container. In this example, our configuration file is named `my-config.json`.

``` bash
docker run -it -v /path/to/config-dir:/config benramsey/slack-irc my-config.json
```

## Configuration File

slack-irc uses Slack's [bot users](https://api.slack.com/bot-users). This means you'll have to set up a bot user as a Slack integration, and invite it to the Slack channels you want it to listen in on. This can be done using Slack's `/invite <botname>` command. This has to be done manually as there's no way to do it through the Slack bot user API at the moment.

slack-irc requires a JSON-configuration file. The configuration file needs to be an object or an array, depending on the number of IRC bots you want to run. This allows you to use one instance of slack-irc for multiple Slack teams if wanted, even if the IRC channels are on different networks.

By default, the Docker container will look for a file named `config.json` in the `/config` directory. You may give this file a different name if you pass the file name as an argument when running the container. The file must be accessible from the `/config` directory in the container; use the `-v` option to tell Docker the path to the host directory you want to expose as `/config` within the running container.

To set the log level to debug, export the environment variable `NODE_ENV` as `development`. For example:

``` bash
docker run -it -v /path/to/config-dir:/config -e NODE_ENV=development benramsey/slack-irc
```

slack-irc also supports invite-only IRC channels, and will join any channels it's invited to as long as they're present in the channel mapping.

### Example configuration

Valid JSON cannot contain comments, so remember to remove them first!

``` js
[
  // Bot 1 (minimal configuration):
  {
    "nickname": "test2",
    "server": "irc.testbot.org",
    "token": "slacktoken2",
    "channelMapping": {
      "#other-slack": "#new-irc-channel"
    }
  },

  // Bot 2 (advanced options):
  {
    "nickname": "test",
    "server": "irc.bottest.org",
    "token": "slacktoken", // Your bot user's token
    "avatarUrl": "https://robohash.org/$username.png?size=48x48", // Set to false to disable Slack avatars
    "slackUsernameFormat": "<$username>", // defaults to "$username (IRC)"; "$username" ovverides so there's no suffix or prefix at all
    "autoSendCommands": [ // Commands that will be sent on connect
      ["PRIVMSG", "NickServ", "IDENTIFY password"],
      ["MODE", "test", "+x"],
      ["AUTH", "test", "password"]
    ],
    "channelMapping": { // Maps each Slack-channel to an IRC-channel, used to direct messages to the correct place
      "#slack": "#irc channel-password", // Add channel keys after the channel name
      "privategroup": "#other-channel" // No hash in front of private groups
    },
    "ircOptions": { // Optional node-irc options
      "floodProtection": false, // On by default
      "floodProtectionDelay": 1000 // 500 by default
    },
    // Makes the bot hide the username prefix for messages that start
    // with one of these characters (commands):
    "commandCharacters": ["!", "."],
    // Prevent messages posted by Slackbot (e.g. Slackbot responses)
    // from being posted into the IRC channel:
    "muteSlackbot": true, // Off by default
    // Sends messages to Slack whenever a user joins/leaves an IRC channel:
    "ircStatusNotices": {
      "join": false, // Don't send messages about joins
      "leave": true
    },
    // Prevent messages posted by users on Slack/IRC from being forwarded:
    "muteUsers": {
      "irc": ["irc-user"],
      "slack": ["slack-user"]
    }
  }
]
```

`ircOptions` is passed directly to node-irc ([available options](http://node-irc.readthedocs.org/en/latest/API.html#irc.Client)).
