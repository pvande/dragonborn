# Dragonborn

> NOTE: Work in Progress!

Dragonborn is a drop-in library to sort out your DragonRuby game's
initialization.

## Rationale

## Usage

Start by saving [dragonborn.rb] into your game's source tree. The entirety
of Dragonborn's functionality is stored in that single file — DragonRuby even
provides [a built-in tool][download_stb] for doing this, which you can run from
your game's console:

```ruby
# Downloads to pvande/dragonborn/dragonborn.rb
$gtk.download_stb_rb "pvande", "dragonborn", "dragonborn.rb"

# OR

# Downloads to wherever/you/want.rb
$gtk.download_stb_rb_raw "https://raw.githubusercontent.com/pvande/dragonborn/main/dragonborn.rb", "wherever/you/want.rb"
```

From there, you can add the following lines to the top of your `app/main.rb`
file:

``` ruby
require "pvande/dragonborn/dragonborn"

Dragonborn.configure do
  root "app"
end
```

By following the Dragonborn convention, Dragonborn will work out an appropriate
load order and automatically require all of the files you ask it to manage.

### Convention

For Dragonborn to work with your project, simply name files and directories
after the classes, modules, and constants they define:

``` text
  # Dragonborn.configure { root "app" }

  app/entity.rb                    -> Entity
  app/entities/player.rb           -> Entities::Player
  app/entities/player/sprite.rb    -> Entities::Player::Sprite
  app/services/movement_service.rb -> Services::MovementService
  app/scenes/settings/audio.rb     -> Scenes::Settings::Audio
```

(In general, this follows the same naming conventions as Rails, if you're
familiar with those.) File and directory names are expected to to be underscore
separated (e.g. `my_long_filename.rb`), and the corresponding constants will be
in "camel case" (e.g. `MyLongFilename`).

**If your project doesn't align perfectly with this convention**, that's fine!
Dragonborn also provides configuration hooks to allow most projects to take
advantage for some or all of their code.

### Concepts

#### Root Directories
In the above example, each file path was mapped to a constant name **based on the
file path relative to `app`**. This is because we configured Dragonborn to use
`app` as a *root directory*, which maps all of its descendants relative to the
top-level Ruby namespace (`Object`).

* Dragonborn can be configured with any number of root directories, and will take
  responsibilty for loading code from all of them.
  * If you do not configure *any* root directories, Dragonborn won't do anything.
* Dependencies between code in different root directories will be automatically
  resolved correctly.
* `app` is not required to be a root directory.
* Root directories may be nested.
  * In the previous example, we could add a second root directory for
    `app/entities`. Doing so would remove the `Entities` namespace from `Player`
    and `Player::Sprite`, but leave the other mappings unaffected.

#### Inflections
When mapping a file or directory name to a constant name, Dragonborn takes the
simple approach of breaking apart the filename into words, capitalizing each
word, and joining them back together again. This works reasonably well in many
cases, but exceptions always exist. One such class of exceptions are acronyms,
which would look ridiculous written out with underscores (e.g.
`h_t_t_p_server.rb`) but can also feel wrong written in with only initial
captial letters (e.g. `Ui::Widget`).

To help resolve this, Dragonborn uses an *inflection map* to override how it
handles specific parts of a name (`html` => `HTML`) or entire names
(`cutscene_keyframes` => `CUTSCENE_KEYFRAMES`).

<!-- resume here -->

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

In cases where the same file belongs to multiple `root` directories, Dragonborn
will always choose the `root` resulting in the shortest constant name.

With multiple `root` directories, it is possible to have multiple files map to
the same constant. Dragonborn automatically detects this case, and will not proceed.

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
[download_stb]: https://docs.dragonruby.org/#/api/runtime?id=download_stb_rb_raw
