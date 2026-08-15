# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  city       :string
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  state      :string
#  street     :string
#  title      :string
#  zip        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials[:GEOCODIO_API_KEY])
    raise ArgumentError 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    reps = []
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    @legislators = fields['congressional_districts'][0]['current_legislators']

    @legislators.each do |official|
      official['name'] = "#{official.dig('bio', 'first_name')} #{official.dig('bio', 'last_name')}"
      title = official['type']
      # Inspect all the data that's there to make part 1 easier.
      # Rails.logger.debug official
      # official.dig('bio', 'party')
      ocdid = official.dig('references', 'govtrack_id')

      reps << Representative.find_rep(official, ocdid: ocdid, title: title)
    end
    reps
  end

  def self.find_rep(official, title: '', ocdid: '')
    rep = Representative.find_or_initialize_by(ocdid: ocdid)
    rep.name = official['name']
    rep.title = title
    rep.update_from_geocodio(official)
    rep
  end

  def update_from_geocodio(official)
    self.title = official['type']
    self.ocdid = official.dig('references', 'govtrack_id')
    self.party = official.dig('bio', 'party')
    self.address = official.dig('contact', 'address')
    self.phone = official.dig('contact', 'phone')
    self.website = official.dig('contact', 'url')
    self.twitter = official.dig('social', 'twitter')
    bioguide_id = official.dig('references', 'bioguide_id')
    self.photo_url =
      ("https://bioguide.congress.gov/bioguide/photo/#{bioguide_id[0]}/#{bioguide_id}.jpg" if bioguide_id.present?)
    # TODO: store the address, phone and website
    save!
    self
  end
end
