ActiveRecord::Associations::HasManyThroughAssociation.class_eval do
  def delete_records(records)
    klass = @reflection.through_reflection.klass
    records.each do |associate|
      klass.destroy_all(construct_join_attributes(associate))
    end
  end
end

# Add an empty method to nil. Now no need for if x and x.empty?. Just x.empty?
class NilClass
  def empty?
    true
  end
end

class ActiveRecord::Base
  def <=>(other)
    self.name <=> other.name
  end

  def update_single_attribute(attribute, value)
    connection.update(
      "UPDATE #{self.class.table_name} " +
      "SET #{attribute.to_s} = #{value} " +
      "WHERE #{self.class.primary_key} = #{id}",
      "#{self.class.name} Attribute Update"
    )
  end

  # ActiveRecord Callback class
  class EnsureNotUsedBy
    def initialize *attribute
      @klasses = attribute
      @logger  = Rails.logger
    end

    def before_destroy(record)
      for klass in @klasses
        for what in record.send(klass.to_sym)
          record.errors.add :base, "#{record} is used by #{what}"
        end
      end
      unless record.errors.empty?
        @logger.error "You may not destroy #{record.to_label} as it is in use!"
        false
      else
        true
      end
    end
  end

  def id_and_type
    "#{id}-#{self.class.table_name.humanize}"
  end
  alias_attribute :to_label, :name
  alias_attribute :to_s, :to_label

  def self.unconfigured?
    first.nil?
  end

end



module ExemptedFromLogging
  def process(request, *args)
    logger.silence { super }
  end
end

class String
  def to_gb
    begin
      value,f,unit=self.match(/(\d+(\.\d+)?) ?(([KMG]B?|B))$/i)[1..3]
      case unit.to_sym
      when nil, :B, :byte          then (value.to_f / 1000_000_000)
      when :GB, :G, :gigabyte      then value.to_f
      when :MB, :M, :megabyte      then (value.to_f / 1000)
      when :KB, :K, :kilobyte, :kB then (value.to_f / 1000_000)
      else raise "Unknown unit: #{unit.inspect}!"
      end
    rescue
      raise "Unknown string: #{self.inspect}!"
    end
  end
end
