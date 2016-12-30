class UserPolicy < ApplicationPolicy

  ######### NOTE #########
  # user == the user doing the action
  # record == the user to which the action is being done

  class Scope < Scope
    def resolve
      active_admin? ? scope : scope.where("users.deactivated_at IS NULL")
    end
  end

  def index?
    active?
  end

  def show?
    active? || self?
  end

  def create?
    active_admin?
  end

  def destroy?
    active_admin? && !record.any_assignments?
  end

  def activate?
    active_admin?
  end

  def deactivate?
    active_admin?
  end

  def invite?
    active_admin?
  end

  def send_invites?
    active_admin?
  end

  def update?
    self? || guardian? || active_admin?
  end

  def administer?
    active_admin?
  end

  # Basic roles are non-admin roles like biller or photographer
  def add_basic_role?
    administer?
  end

  def cluster_adminify?
    active? && user.has_role?(:cluster_admin)
  end

  def super_adminify?
    active? && user.has_role?(:super_admin)
  end

  def permitted_attributes
    # We don't include household_id here because that must be set explicitly because the admin
    # community check relies on it.
    household_permitted = HouseholdPolicy.new(user, record.household).permitted_attributes
    permitted = [:email, :first_name, :last_name, :mobile_phone, :home_phone, :work_phone,
      :photo, :photo_tmp_id, :photo_destroy, :birthdate_str, :child, :joined_on,
      :preferred_contact, :household_by_id]
    permitted << {up_guardianships_attributes: [:id, :guardian_id, :_destroy]}

    # We allow household_attributes.id through here even though changing the household ID is very sensitive
    # security-wise. But Rails doesn't let you set change the ID this way. It only uses the ID to determine
    # if you are passing in a new object or modifying an exsiting one. If you try to pass an ID that is
    # different from user.household_id (even if the latter is nil), ActiveRecord::RecordNotFound will be
    # raised. Therefore the only way to change the household_id is via the attribute itself, and allowing
    # ID through here is safe.
    permitted << {household_attributes: [:id] + household_permitted}

    permitted.concat([:google_email, :alternate_id]) if active_admin?
    grantable_roles.each { |r| permitted << :"role_#{r}" }
    permitted
  end

  def grantable_roles
    (active_admin? ? [:admin, :biller] : []) +
    (active_cluster_admin? ? [:cluster_admin] : []) +
    (active_super_admin? ? [:super_admin] : [])
  end

  private

  def self?
    record == user
  end

  # Checks if the user is a guardian of the user being tested.
  def guardian?
    record.guardians.include?(user)
  end
end
