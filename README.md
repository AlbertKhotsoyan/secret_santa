# Secret Santa
A Redmine plugin that allows users to participate in a Secret Santa game directly inside Redmine.
Players register themselves, add their gift preferences, and an administrator manages the game, runs the draw, and sends personalized email notifications using template variables.

## Supported Redmine Versions
* Redmine 5.0
* Redmine 5.1
* Redmine 6.0
* Redmine 6.1

## Supported Languages
* English (en)
* Russian (ru)

## Installation
1. Copy the plugin folder to:
`redmine_root/plugins/secret_santa`
2. Restart Redmine. 
3. The plugin page will appear in the main-menu bar of `/projects`


## How to use
### 1. Player Registration

Each Redmine user who wants to participate must create a Player from their own account.

A player can enter:
* wishes / preferred gifts
* gifts they do not want

This information is private and visible only to the player.


### 2. Game Management

The administrator creates a Secret Santa Game and configures Email subject and body using template variables.

After a game is created, the admin can:
* add all registered players to the game and run the draw to assign each giver a receiver
* update the player list and draw later if new players register


### 3. Sending Notification Emails

Once the draw is complete and the roster is finalized, the admin send personalized email letters to all givers.


### Email Template Example
`Hello ((Giver_name)),`

`You should prepare a gift for ((Receiver_name)).`

`Receiver prefer:`
`((Receiver_preferred_gifts))`

`Receiver prefer to avoid:`
`((Receiver_avoid_these_gifts))`
