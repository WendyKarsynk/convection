# frozen_string_literal: true

module Mutations
  class CreateSubmissionMutation < Mutations::BaseMutation
    argument :artistID, String, required: true

    argument :additional_info, String, required: false
    argument :attribution_class, Types::AttributionClassType, required: false
    argument :authenticity_certificate, Boolean, required: false
    argument :category, Types::CategoryType, required: false
    argument :coaByAuthenticatingBody, Boolean, required: false
    argument :coaByGallery, Boolean, required: false
    argument :currency, String, required: false
    argument :depth, String, required: false
    argument :dimensions_metric,
             String,
             required: false,
             prepare: ->(value, _context) { value.downcase }
    argument :edition, Boolean, required: false
    argument :edition_number, String, required: false
    argument :edition_size,
             Integer,
             required: false,
             description: 'Deprecated: Use edition_size_formatted field instead'
    argument :edition_size_formatted, String, required: false
    argument :height, String, required: false
    argument :location_city, String, required: false
    argument :location_country, String, required: false
    argument :location_state, String, required: false
    argument :location_postal_code, String, required: false
    argument :location_country_code, String, required: false
    argument :medium, String, required: false
    argument :minimum_price_dollars, Integer, required: false
    argument :myCollectionArtworkID, String, required: false
    argument :provenance, String, required: false
    argument :signature, Boolean, required: false
    argument :sourceArtworkID,
             String,
             required: false,
             description: 'If this artwork exists in Gravity, its ID'
    argument :state, Types::StateType, required: false
    argument :title, String, required: false
    argument :user_agent, String, required: false
    argument :user_name, String, required: false
    argument :user_email, String, required: false
    argument :user_phone, String, required: false
    argument :width, String, required: false
    argument :year, String, required: false
    argument :utm_source, String, required: false
    argument :utm_medium, String, required: false
    argument :utm_term, String, required: false
    argument :sessionID, String, required: false
    argument :source, Types::SubmissionSourceType, required: false

    field :consignment_submission, Types::SubmissionType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = CreateSubmissionResolver.new(**resolve_options)

      resolver.run
    end
  end
end
