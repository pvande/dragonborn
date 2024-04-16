# Dragonborn

> NOTE: Work in Progress!

Dragonborn is a drop-in library to sort out your DragonRuby game's
initialization.

## Rationale

## Usage

To get started, save [dragonborn.rb] into your game's source tree.

From there, you can add the following lines to the top of your `app/main.rb`
file:

``` ruby
# This assumes that you saved it under your game's `lib` directory.
require "lib/dragonborn"

Dragonborn.configure do
  # Your configuration goes here. e.g.
  root "app"
end
```

By following the Dragonborn convention, Dragonborn will work out an appropriate
load order and automatically require all of the files you ask it to manage.

### Convention

Like the Rails class naming convention, Dragonborn expects that each file path
beneath a named [root](#root-dir) corresponds to the full name of a constant in
Ruby. For example, the root-relative path `entities/player.rb` corresponds to
the Ruby constant `Entities::Player`.

File and directory names are expected to tbe underscored
(e.g. `my_long_filename`), and the corresponding constants will be initially
capitalized (e.g. `MyLongFilename`). Acronyms and exceptional mappings [may be
configured](#inflection-word--word) as well.

### Configuration

#### root [dir]
The `root` configuration option indicates that this is a directory Dragonborn
should autoload source code from. This option may be supplied multiple times,
and may overlap each other.

Specifying `root` directories closer to the files being required will
effectively "shrink" the expected Ruby constant name.

``` ruby
# Given a file at "app/components/player/movement.rb"…

Dragonborn.configure { root "app" }
# … expects to load `Components::Player::Movement`

Dragonborn.configure { root "app/components" }
# … expects to load `Player::Movement`

Dragonborn.configure { root "app/components/player" }
# … expects to load `Movement`
```

#### ignore [filepath]
The `ignore` configuration option instructs Dragonborn to skip autoloading the
named file. This can be useful when dealing with files that don't implicitly
create a constant, or don't follow Dragonborn's conventions.

`app/main` is implicitly ignored.

#### inflection [word] => [Word]
#### inflection [underscored_name] => [CamelCasedName]
Custom `inflection`s can be defined as well — these give Dragonborn hints about
how to transform your filenames into Ruby constant names.

``` ruby
# Given a file at "app/ui/button.rb"…

Dragonborn.configure { root "app" }
# … expects to load `Ui::Button

Dragonborn.configure do
  root "app"
  inflection "ui" => "UI"
end
# … expects to load `UI::Button`
```

[dragonborn.rb]: https://raw.githubusercontent.com/pvande/dragonborn/main/dragonborn.rb
