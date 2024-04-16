CONST = "::CONST"

class Entity
  CONST = "Entity::CONST"
end

class Person < Entity
  CONST = "Person::CONST"

  class Sprite < Entity
  end
end

class Person::Box < Entity
end

# --- #

class Entity
  def const
    CONST
  end
end

# Regardless of subclass, this returns the same value. Even though the *method*
# is inherited, it uses the constant "nearest" the method definition.
puts Entity.new.const         # => "Entity::CONST"
puts Person.new.const         # => "Entity::CONST"
puts Person::Sprite.new.const # => "Entity::CONST"
puts Person::Box.new.const    # => "Entity::CONST"
puts

# --- #

class Entity
  def lexical_const
    CONST
  end
end

class Person
  def lexical_const
    CONST
  end

  class Sprite
    def lexical_const
      CONST
    end
  end
end

class Person::Box
  def lexical_const
    CONST
  end
end

# By defining a new method in each subclass, the constant varies by subclass. If
# the subclass *doesn't* define its own constant, the constant is automatically
# found in the nearest namespace that does. Note the value for `Person::Sprite`.
puts Entity.new.lexical_const         # => "Entity::CONST"
puts Person.new.lexical_const         # => "Person::CONST"
puts Person::Sprite.new.lexical_const # => "Person::CONST"
puts Person::Box.new.lexical_const    # => "Entity::CONST"
puts

# --- #

class Entity
  def ancestral_const
    self.class::CONST
  end
end

# If we specify that we should lookup the constant from the object's class, we
# bypass the lexical lookup behavior. Note the value of `Person::Sprite` has
# changed, since `Person::Sprite` is *lexically defined* within `Person`, but
# *inherits* from `Entity`.
puts Entity.new.ancestral_const         # => "Entity::CONST"
puts Person.new.ancestral_const         # => "Person::CONST"
puts Person::Sprite.new.ancestral_const # => "Entity::CONST"
puts Person::Box.new.ancestral_const    # => "Entity::CONST"
puts

# --- #

class Entity
  def self.scoped_const
    CONST
  end
end

def Person.scoped_const
  CONST
end

Person::Box.define_singleton_method(:scoped_const) do
  CONST
end

# Finally, if we define the method outside of an open namespace, constant lookup
# resolves to the "nearest" defined constant.
puts Entity.scoped_const         # => "Entity::CONST"
puts Person.scoped_const         # => "::CONST"
puts Person::Sprite.scoped_const # => "Entity::CONST"
puts Person::Box.scoped_const    # => "::CONST"
puts
