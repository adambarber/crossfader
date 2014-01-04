# Crossfader

The Crossfader gem is a command line interface for the Crossfader.fm API. If you need to manage a large number of loops, then this is the tool for you.

## Installation

1. Install the LAME mp3 encoder.
2. Install this gem with `gem install crossfader`
3. Authorize this app
4. Begin managing your Crossfader library.

## Usage

You can perform the following actions:
---

`crossfader auth` Authorize this app to work with the Crossfader.fm API.
`crossfader convert` : Convert a folder of .wav files to .mp3.
`crossfader upload` : Upload a folder of .mp3s to the server to create new loops.
`crossfader batch` : Create a new pack, convert a folder of .wav files to .mp3 files and upload them to the server in one step.
`crossfader create_pack` : Create a new empty pack.
`crossfader help` : To see this menu.

---
Have questions, comments, or feed back? Contact Adam at adam@djz.com

To get started, you must first authorize the app and get your api access token.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
