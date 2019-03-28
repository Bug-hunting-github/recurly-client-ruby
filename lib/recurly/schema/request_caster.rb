require 'date'

module Recurly
  class Schema
    # *Note*: This class is for internal use.
    # The RequestCaster turns mixed data into a pure Hash
    # so it can be serialized into JSON and used as the body of a request.
    # This module is to be extended by the Request class.
    module RequestCaster
      # This method casts the data object (of mixed types) into a Hash ready for JSON
      # serialization. The *schema* will default to the self's schema.
      # You should pass in the schema where possible. This is because objects are serialized
      # differently depending on the context in which they are being written.
      #
      # @example
      #   Recurly::Requests::AccountUpdatable.cast(account_code: 'benjamin')
      #   #=> {:account_code=>"benjamin"}
      # @example
      #   # If you have some mixed data, like passing in an Address, it should cast that
      #   # address into a Hash based on the Schema defined in AccountUpdatable
      #   address = Recurly::Resources::Address.new(city: 'New Orleans')
      #   Recurly::Requests::AccountUpdatable.cast(account_code: 'benjamin', address: address)
      #   #=> {:account_code=>"benjamin", :address=>{:city=>"New Orleans"}}
      #
      # @param data [Hash,Resource,Request] The data to transform into a JSON Hash.
      # @param schema [Schema] The schema to use to transform the data into a JSON Hash.
      # @return [Hash] The pure Hash ready to be serialized into JSON.
      def cast(data, schema=self.schema)
        casted = {}
        if data.is_a?(Resource) || data.is_a?(Request)
          data = as_json(data, schema)
        end

        data.each do |k,v|
          schema_attr = schema.get_attribute(k)
          norm_val = if v.respond_to?(:attributes)
                       cast(v, schema_attr.recurly_class.schema)
                     elsif v.is_a?(Array)
                       v.map do |elem|
                         if elem.respond_to?(:attributes)
                           cast(elem, schema_attr.recurly_class.schema)
                         else
                           elem
                         end
                       end
                     elsif v.is_a?(Hash) && schema_attr && schema_attr.type.is_a?(Symbol)
                       cast(v, schema_attr.recurly_class.schema)
                     else
                       v
                     end

          casted[k] = norm_val
        end

        casted
      end

      private

      def as_json(resource, schema)
        writeable_attributes = schema.attributes.reject(&:read_only?).map(&:name)
        resource.attributes.select { |k,_| writeable_attributes.include?(k) }
      end
    end
  end
end
