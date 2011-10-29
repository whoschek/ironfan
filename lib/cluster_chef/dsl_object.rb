module ClusterChef
  #
  # Provides magic methods, defined with has_keys
  #
  # @example
  #   class Mom < ClusterChef::DslObject
  #     has_keys(:college, :combat_boots, :fat, :so_fat)
  #   end
  #
  #   class Person
  #     def momma &block
  #       @momma ||= Mom.new
  #       @momma.configure(&block) if block
  #     end
  #   end
  #
  #   yo = Person.new
  #   yo.mamma.combat_boots :wears
  #   yo.momma do
  #     fat    true
  #     so_fat 'When she sits around the house, she sits *AROUND* the house'
  #   end
  #
  class DslObject
    class_attribute :keys
    self.keys = []

    def initialize(attrs={})
      @settings = attrs || Mash.new
    end

    #
    # Defines DSL attributes
    #
    # @params [Array(String)] key_names DSL attribute names
    #
    # @example
    #   class Mom < ClusterChef::DslObject
    #     has_keys(:fat, :so_fat)
    #   end
    #   yer_mom = Mom.new
    #   yer_mom.fat :quite
    #
    def self.has_keys(*key_names)
      key_names.map!(&:to_sym)
      self.keys += key_names
      key_names.each do |key|
        define_method(key){|*args| set(key, *args) }
      end
    end

    #
    # Sets the DSL attribute, unless the given value is nil.
    #
    def set(key, val=nil)
      @settings[key] = val unless val.nil?
      @settings[key]
    end

    def to_hash
      @settings.dup
    end

    def to_s
      "<#{self.class} #{to_hash.inspect}>"
    end

    def reverse_merge!(hsh)
      @settings.reverse_merge!(hsh.to_hash)
    end

    def configure(hsh={}, &block)
      @settings.merge!(hsh.to_hash)
      instance_eval(&block) if block
      self
    end

    # helper method for bombing out of a script
    def die(*args) ClusterChef.die(*args) ; end

    # helper method for turning exceptions into warnings
    def safely(*args, &block) ClusterChef.safely(*args, &block) ; end

    # helper method for debugging only
    def dump(*args) args.each{|arg| Chef::Log.debug( [caller.first, arg].inspect ) } end
  end
end
