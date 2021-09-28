module Recurly
  # Recurly Documentation: https://developers.recurly.com/api-v2/latest/index.html#tag/dunning-campaigns
  class DunningCampaign < Resource
    # @return [[DunningCycle], []]
    has_many :dunning_cycles
    has_many :plans

    define_attribute_methods %w(
      id
      name
      code
      description
      default
      dunning_cycles
      created_at
      updated_at
      deleted_at
      plans
    )

    def bulk_update(plan_codes)
      return false unless link? :bulk_update

      builder = XML.new("<dunning_campaign/>")
      node = builder.add_element 'plan_codes'
      plan_codes.each { |plan_code| node.add_element 'plan_code', plan_code }

      reload follow_link(:bulk_update, :body => builder.to_s)
    end
  end
end
