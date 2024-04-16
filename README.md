# Dragonborn

> NOTE: Work in Progress!

Dragonborn is a drop-in library to sort out your DragonRuby game's
initialization.

## Rationale

Managing `require` statements isn't fun.

Building a game is complicated, and involves a lot of decisions that around
logic, aesthetics, timing, narrative, and many other factors. DragonRuby GTK
provides a fantastic platform for quickly building a prototype, and gradually
evolving it into a publication-ready game — giving you creative freedom for both
your game and your code structure. As your game spreads out across multiple
files, however, it becomes necessary for *this* file to use things from this
*other* file, which affects the order that you have to `require` those files in…

It doesn't take many repetitions before remembering that order becomes a burden.

If you're familiar with Ruby from using Rails, you're probably used to having
the platform figure all that out for you. If you create a file named
`person.rb` and that file contains a class named `Person`, you don't worry about
`require` at all — you just _use `Person`_ wherever you need it. Combined with
something like hotloading (where your code changes are automatically applied),
you can enter a powerful flow state where you stop editing *files* and start
editing *the application directly*.

Dragonborn exists to bring that same workflow to DragonRuby, making it just that
*little* bit easier to **finish your game**.

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

This loads Dragonborn into your application, and directs it to manage and load
all Ruby code within your `app` directory. By following the Dragonborn naming
conventions, Dragonborn automatically works out an appropriate load order and
requires all of the files in its purview.

---

Many projects also have a "junk drawer" — one (or more!) directories of files
that contain the variety of helper functions, library patches, and other
assorted code that your application relies on. For cases like these, Dragonborn
also includes a helper to just require each file.

``` ruby
# Requires all files in the "patches" directory, but not subdirectories.
Dragonborn.require_dir("patches")
```

These files are not considered "managed" by Dragonborn; it simply iterates
through the files in that directory and `require`s them. This makes it well
suited for requiring files in bulk that may or may not follow convention, and
which don't have load order considerations.

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

### Configuration

Inside the block passed to `Dragonborn.configure`, you tell Dragonborn how your
project is structured by calling the following configuration functions.

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

### Caveats

* Dragonborn has a constant lookup algorithm that is *slightly* different than
  what's described by the Ruby standard. Specifically, Ruby's constant lookup
  searches the ancestors of *each open namespace*. This is reasonably intuitive
  as you're writing code, but makes metaprogramming life more difficult. (For an
  example, see [caveats/examples/constant_lookup.rb].)

  Dragonborn works by exploiting the `const_missing` functionality in Ruby to
  load your code as it's needed. In doing so, any information about which
  namespaces were open at the location that the const was looked up is lost.
  Since that information is required to perfectly replicate Ruby's native
  constant lookup, **Dragonborn will find different constants in some cases**.

  To minimize the odds of running afoul of this behavior, avoid defining your
  classes and modules with the "compact" (`::`-separated) syntax, and be mindful
  about constant lookups in dynamically defined methods.

  ``` ruby
  # AVOID:
  class Foo::Bar::Baz
    # Constants looked up here will resolve incorrectly in Dragonborn!
  end

  # INSTEAD:
  class Foo
    class Bar
      class Baz
        # This is more verbose and more indentation, but Dragonborn's behavior
        # will match Ruby's!
      end
    end
  end

  # --- #

  # AVOID:
  Foo.define_method(:bar) { CONST }

  # INSTEAD:
  class Foo
    define_method(:bar) { CONST }
  end

  # --- #

  # AVOID:
  def Foo.bar
    CONST
  end

  # INSTEAD:
  class Foo
    def self.bar
      CONST
    end
  end
  ```

[dragonborn.rb]: https://raw.githubusercontent.com/pvande/dragonborn/main/dragonborn.rb
[download_stb]: https://docs.dragonruby.org/#/api/runtime?id=download_stb_rb_raw
