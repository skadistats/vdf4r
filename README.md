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

    gem 'vdf4r', '~>0.1.0'


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

I'll think of a way to make the parser more permissive as time allows.


## Hacking

Just clone the source from here. If issuing a pull request, make sure your
change is on a topic branch accompanied by new tests; all behaviors must pass.


## License

VDF4R is offered under the MIT license. See [LICENSE](https://github.com/skadistats/vdf4r/blob/master/README.md)
for the license itself.
