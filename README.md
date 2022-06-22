# SWGOH Companion

SWGOH Companion is a project consisting of bounty hunters aiming to help you analyze data (bounties) from SWGOH.

## Setup

The main storage and UI is Google Spreadsheets, so you will need to set it up.

For setting it up you need to setup a service-account.json as described in [Elixir Google Spreadsheets](https://github.com/Voronchuk/elixir_google_spreadsheets).

## Generating new hunters and running them

  Example generating new hunter:
  ```shell
  mix hunter.gen upsert_characters --sheet "Characters"
  ```

  To run a hunter just execute the associated shell script:
  ```shell
  bin/upsert_characters.sh
  ```