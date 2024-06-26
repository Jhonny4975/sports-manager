# frozen_string_literal: true

module SportsManager
  # TODO: change the name Group. In terms of sports tournament it means something else.
  # Public: A category with teams and matches between them
  class Group
    attr_reader :category, :initial_matches, :teams

    def self.for(category:, subscriptions:, matches:)
      GroupBuilder.new(category: category, subscriptions: subscriptions, matches: matches).build
    end

    def initialize(category: nil, matches: nil, teams: nil)
      @category = category
      @initial_matches = matches
      @teams = teams
    end

    def participants
      @participants ||= teams.map(&:participants).flatten
    end

    # Internal: Combine matches, byes and next round matches
    def all_matches
      @all_matches ||= (initial_matches | (matches_generated? ? [] : future_matches))
    end

    def matches
      @matches ||= all_matches.select(&:playable?)
    end

    def first_round_matches
      find_matches(0)
    end

    def find_matches(round_number)
      matches.select { |match| match.round == round_number }
    end

    def future_matches
      Matches::NextRound
        .new(category: category, base_matches: initial_matches)
        .next_matches
    end

    def find_participant_matches(participant)
      matches.select do |match|
        match.participants.include? participant
      end
    end

    private

    # Verifies if the matches were passed already generated
    # if depends_on is not empty, the match was passed already generated
    def matches_generated?
      initial_matches.any? { |match| !match.depends_on.empty? }
    end
  end
end
