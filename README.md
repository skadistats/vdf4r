# VDF4R

Parse Valve Data Format files easily and quickly.


## Context

Valve has its own data format for storing game information. This library lets
you parse these files into a plain-old Ruby hash easily and quickly.

After that, you can do with the data what you will.


## Installation

As normal:

    gem install vdf4r

Or in your Gemfile:

    gem 'vdf4r'


## Usage

    require 'vdf4r'
    require 'pp'

    File.open('vdf_file.txt') do |file|
      parser = VDF4R::Parser.new(file)
      pp parser.parse # pretty-printed
    end


## Caveats

This library has only really been used on a few Dota 2 VDF files. It's not
battle-tested yet, and there are probably some minor issues.

If you find something you'd like to discuss, you can find me on #dota2replay
on quakenet IRC.

At least one of Dota 2's own VDF files have grammar mistakes.
(i.e. npc_abilities.txt) If you get an "ungrammatical content" error while
parsing, you will need to fix the error. It will give you the offending line:

    (RuntimeError)parser.rb:30:in `block in parse': ungrammatical content: '        / Damage.
    '

Indeed, in the VDF file, there are "comment" lines lacking the proper '//'
prefix. When I changed the file to contain '// Damage.' it parsed correctly.

Another thing you'll see, specifically in `dota_english.txt` is the placement
of two key/value pairs on one line. This will have to be fixed manually, since
it's an outright error:

    "DOTA_Tooltip_ability_item_mjollnir_static_duration"          "STATIC DURATION:"    "DOTA_Tooltip_ability_item_mjollnir_static_damage"            "STATIC DAMAGE:"

This can be fixed like so if you encounter similar errors:

    "DOTA_Tooltip_ability_item_mjollnir_static_duration"          "STATIC DURATION:"
    "DOTA_Tooltip_ability_item_mjollnir_static_damage"            "STATIC DAMAGE:"

I'll try to make the parser more permissive as time allows.


## Hacking

Just clone the source from here. If issuing a pull request, make sure your
change is on a topic branch accompanied by new tests; all behaviors must pass.


## License

VDF4R is offered under the MIT license. See [LICENSE](https://github.com/skadistats/vdf4r/blob/master/LICENSE)
for the license itself.
