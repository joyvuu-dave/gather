class Signup < ActiveRecord::Base
  MAX_PEOPLE_PER_TYPE = 10
  MAX_COMMENT_LENGTH = 500
  DINER_TYPES = %w(adult senior teen big_kid little_kid)
  FOOD_TYPES = %w(meat veg)
  SIGNUP_TYPES = DINER_TYPES.map { |dt| FOOD_TYPES.map { |ft| "#{dt}_#{ft}" } }.flatten
  VEG_SIGNUP_TYPES = DINER_TYPES.map { |dt| "#{dt}_veg" }
  PORTION_FACTORS = {
    senior: 0.75,
    adult: 1,
    teen: 0.75,
    big_kid: 0.5,
    little_kid: 0
  }

  acts_as_tenant(:cluster)

  belongs_to :meal, inverse_of: :signups
  belongs_to :household

  scope :community_first, ->(c) do
    includes(household: :community).order("CASE WHEN communities.id = #{c.id} THEN 0 ELSE 1 END")
  end
  scope :sorted, -> { joins(household: :community).order('communities.abbrv, households.name') }

  normalize_attributes :comments

  validates :comments, length: {maximum: MAX_COMMENT_LENGTH}
  validate :max_signups_per_type, :dont_exceed_spots, :nonzero_signups_if_new

  delegate :name, :users, :adults, to: :household, prefix: true
  delegate :community_abbrv, to: :household
  delegate :communities, to: :meal

  before_update do
    destroy if all_zero?
  end

  def self.for(user, meal)
    find_or_initialize_by(household_id: user.household_id, meal_id: meal.id)
  end

  def self.total_for_meal(meal)
    where(meal_id: meal.id).sum(SIGNUP_TYPES.join("+"))
  end

  def self.totals_for_meal(meal)
    query = where(meal_id: meal.id)
    SIGNUP_TYPES.each{ |st| query = query.select("SUM(#{st}) AS #{st}") }
    query.to_a.first.attributes.slice(*SIGNUP_TYPES).tap do |totals|
      # Totals may be nil if no signups. Ensure zeros instead.
      totals.each { |k, v| totals[k] ||= 0 }
    end
  end

  def self.portions_for_meal(meal, food_type)
    totals = totals_for_meal(meal)
    DINER_TYPES.map { |dt| totals["#{dt}_#{food_type}"] * PORTION_FACTORS[dt.to_sym] }.reduce(:+)
  end

  def self.all_zero_attribs?(attribs)
    attribs.slice(*SIGNUP_TYPES).values.map(&:to_i).uniq == [0]
  end

  def save_or_destroy
    all_zero? && persisted? ? destroy : save
  end

  def count_for(diner_type, food_type)
    self["#{diner_type}_#{food_type}"]
  end

  def total
    @total ||= SIGNUP_TYPES.inject(0) { |sum, t| sum += (send(t) || 0) }
  end

  def total_was
    SIGNUP_TYPES.inject(0) { |sum, t| sum += (send("#{t}_was") || 0) }
  end

  # The diff in the current total minus the total before the current update
  def total_change
    total - total_was
  end

  def all_zero?
    SIGNUP_TYPES.all? { |t| self[t] == 0 }
  end

  def allowed?
    # If the signup has already been saved, then it was allowed.
    # Otherwise we ask meal if new signups are allowed.
    !new_record? || meal.new_signups_allowed?
  end

  def not_allowed?
    !allowed?
  end

  private

  def max_signups_per_type
    SIGNUP_TYPES.each do |t|
      errors.add(t, "maximum of #{MAX_PEOPLE_PER_TYPE}") if send(t) > MAX_PEOPLE_PER_TYPE
    end
  end

  def dont_exceed_spots
    if !meal.finalized? && total_change > meal.spots_left
      errors.add(:base, :exceeded_spots, count: meal.spots_left + total_was)
    end
  end

  def nonzero_signups_if_new
    if new_record? && all_zero?
      errors.add(:base, "You must sign up at least one person")
    end
  end
end
