class MealPolicy < ApplicationPolicy
  alias_method :meal, :record

  class Scope < Scope
    ASSIGNED = "EXISTS (SELECT id FROM assignments
      WHERE assignments.meal_id = meals.id AND assignments.user_id = ?)"
    INVITED = "EXISTS (SELECT id FROM invitations
      WHERE invitations.meal_id = meals.id AND invitations.community_id = ?)"
    SIGNED_UP = "EXISTS (SELECT id FROM signups
      WHERE signups.meal_id = meals.id AND signups.household_id = ?)"

    def resolve
      if user.active?
        scope.where("#{ASSIGNED} OR #{INVITED} OR #{SIGNED_UP}", user.id, user.community_id, user.household_id)
      else
        scope.where(SIGNED_UP, user.household_id)
      end
    end
  end

  def index?
    active?
  end

  def show?
    active_and_associated_or_signed_up?
  end

  def reports?
    index?
  end

  def jobs?
    index?
  end

  def create?
    active_admin?
  end

  def update?
    active? && (host? || assigned?)
  end

  # Means they can peform the fundamental tasks (set date, communities, etc.)
  def administer?
    active_admin? && host? || active_super_admin?
  end

  def destroy?
    administer?
  end

  def summary?
    active_and_associated_or_signed_up?
  end

  def set_menu?
    hosting_admin_or_head_cook?
  end

  def close?
    hosting_admin_or_head_cook?
  end

  def reopen?
    hosting_admin_or_head_cook? && !meal.in_past?
  end

  def finalize?
    host? && active_admin_or_biller?
  end

  def contact?
    @contact ||= Meals::MessagePolicy.new(user, Meals::Message.new(meal: record)).create?
  end
  alias_method :contact_diners?, :contact?
  alias_method :contact_team?, :contact?

  def permitted_attributes
    # Anybody that can update a meal can change the assignments.
    permitted = [{
      :head_cook_assign_attributes => [:id, :user_id],
      :asst_cook_assigns_attributes => [:id, :user_id, :_destroy],
      :table_setter_assigns_attributes => [:id, :user_id, :_destroy],
      :cleaner_assigns_attributes => [:id, :user_id, :_destroy]
    }]

    if set_menu?
      allergens = Meal::ALLERGENS.map{ |a| :"allergen_#{a}" }
      permitted += allergens + [:title, :capacity, :entrees, :side, :kids, :dessert, :notes,
        { :community_boxes => [Community.all.map(&:id).map(&:to_s)] }
      ]
    end

    if administer?
      permitted += [:discount, :served_at, resource_ids: []]
    end

    permitted
  end

  private

  def hosting_admin_or_head_cook?
    active_admin? && host? || active? && head_cook?
  end

  def host?
    not_specific_record? || user.community == meal.community
  end

  def active_and_associated_or_signed_up?
    active? && associated? || signed_up?
  end

  def associated?
    invited? || assigned? || signed_up?
  end

  def invited?
    meal.communities.include?(user.community)
  end

  def assigned?
    meal.assignments.any?{ |a| a.user == user }
  end

  def signed_up?
    meal.signups.any?{ |s| s.household == user.household }
  end

  def head_cook?
    user == meal.head_cook
  end
end
