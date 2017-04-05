module CustomFields
  module Entries
    # A set of Entrys corresponding to a GroupField in the Spec.
    class GroupEntry < Entry
      include ActiveModel::Validations

      attr_accessor :entries

      delegate :root?, to: :field

      validate :validate_children

      def initialize(field:, hash:, parent: nil)
        super(field: field, hash: hash, parent: parent)
        self.entries = field.fields.map { |f| build_child_entry(f) }

        # Define methods instead of using method_missing because it's cleaner and
        # this way we can override the many Object instance methods that we don't use here.
        # If we use method missing we have to reserve all of those and there are plenty of useful
        # words in there like method, display, extend, etc.
        field.fields.each do |f|
          define_singleton_method(f.key) { self[f.key] }
          define_singleton_method("#{f.key}=") { |value| self[f.key] = value }
        end
      end

      def model_name
        @model_name ||= ActiveModel::Name.new(self.class, nil, key.to_s)
      end

      def keys
        entries_by_key.keys
      end

      def value
        self
      end

      def [](key)
        entries_by_key[key.to_sym].try(:value)
      end

      def []=(key, new_value)
        entries_by_key[key.to_sym].try(:update, new_value)
      end

      def update(new_hash)
        check_hash(new_hash)
        new_hash = new_hash.with_indifferent_access
        entries.each do |entry|
          if new_hash.has_key?(entry.key)
            entry.update(new_hash[entry.key])
          end
        end
      end

      # Runs validations and sets error on parent GroupEntry if invalid
      def do_validation(parent)
        parent.errors.add(key, :invalid) unless valid?
      end

      # Returns an i18n_key of the given type (e.g. `errors`, `placeholders`).
      # If `suffix` is true, adds `._self` on the end,
      # for when the group itself needs a translation.
      def i18n_key(type, suffix: true)
        (super.to_s << (suffix ? "._self" : "")).to_sym
      end

      def entries_by_key
        @entries_by_key ||= entries.map { |e| [e.key, e] }.to_h
      end

      private

      def class_for(field)
        field.type == :group ? GroupEntry : BasicEntry
      end

      def build_child_entry(field)
        class_for(field).new(field: field, hash: hash_for_child, parent: self)
      end

      # The hash we should pass to any child entries we build.
      def hash_for_child
        hash[key] = {} if hash[key].nil?
        hash[key]
      end

      # Runs the validations specified in the `validations` property of any children.
      def validate_children
        entries.each { |e| e.do_validation(self) }
      end
    end
  end
end