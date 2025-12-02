# Secret Santa
A Redmine plugin that allows users to participate in a Secret Santa game directly inside Redmine.
Users register as players, add their gift preferences, and an administrator manages the game, performs the draw, and sends personalized emails using template variables.

## Supported Redmine Versions
* Redmine **5.0, 5.1, 6.0, 6.1**

## Supported Databases
* PostgreSQL

## Supported Languages
* English (en)
* Russian (ru)

## Installation
1. Copy the plugin folder to:
   `redmine/plugins/secret_santa`
2. Restart Redmine.
3. The plugin page will appear in the main-menu bar of `/projects`

## Requirements
Each participating user **must have a valid email address** in their Redmine account.
This is the email where their Secret Santa assignment will be delivered after the draw.

## Security & Privacy

A player specified information of preferred gifts is private and visible only to:
* the player
* the database admin (through direct DB access)

After a user receives their Secret Santa assignment email, they or a Redmine admin can **delete the player** record to remove their personal wishes from the database.

After the **redmine admin sends** all Secret Santa emails, they **should delete the game**, which removes all assignment records from the database.

This ensures that personal preferences and assignment data are stored only for the duration of the event.

## How to use
### 1. Player Registration

Each Redmine user who wants to participate must create a Player from their own account.

A player can define:
* preferred gifts
* gifts they want to avoid


### 2. Game Management

The administrator creates a Secret Santa Game and configures Email subject and body using template variables.

After a game is created, the admin can:
* add all registered players to the game and run the draw to assign each giver a receiver
* update the player list and draw later if new players register


### 3. Sending Notification Emails

Once the draw is completed and the player list is final, the administrator can send personalized assignment emails.
Each participant receives their message at the email specified in their Redmine profile.

### Email Template Example
`Hello ((Giver_name)),`

`You should prepare a gift for ((Receiver_name)).`

`Receiver prefer:`
`((Receiver_preferred_gifts))`

`Receiver prefer to avoid:`
`((Receiver_avoid_these_gifts))`
