require 'rails_helper'

describe HouseholdPolicy do
  include_context "policy objs"

  describe "permissions" do
    let(:record) { household }

    shared_examples_for "permits admins and members of household" do
      # We don't need to check cluster admins/super admins here or in every other place where
      # admin permissions are tested. We are trusting the active_admin? method which is tested elsewhere.
      it "grants access to admins" do
        expect(subject).to permit(admin, record)
      end

      it "grants access for regular users to own household" do
        expect(subject).to permit(user, user.household)
      end

      it "denies access to regular users to other households" do
        expect(subject).not_to permit(user, Household.new)
      end
    end

    shared_examples_for "permits action on own community" do
      it "permits action on households in same community" do
        expect(subject).to permit(user, other_user.household)
      end

      it "permits action on inactive households" do
        expect(subject).to permit(user, inactive_household)
      end
    end

    shared_examples_for "permits action on own cluster but not outside" do
      it_behaves_like "permits action on own community"

      it "permits action on households in other community in cluster" do
        expect(subject).to permit(user, user_in_cluster.household)
      end

      it "permits outside super admins" do
        expect(subject).to permit(outside_super_admin, user_in_cluster.household)
      end

      it "denies action on households outside cluster" do
        expect(subject).not_to permit(user, outside_user.household)
      end
    end

    shared_examples_for "permits action on own community users but denies on all others" do
      it_behaves_like "permits action on own community"

      it "denies action on households in other community in cluster" do
        expect(subject).not_to permit(user, user_in_cluster.household)
      end

      it "denies action on households outside cluster" do
        expect(subject).not_to permit(user, outside_user.household)
      end
    end

    permissions :index?, :show? do
      it_behaves_like "permits action on own cluster but not outside"
    end

    permissions :show_personal_info? do
      it_behaves_like "permits action on own community users but denies on all others"
    end

    permissions :new?, :create?, :activate?, :deactivate?, :administer? do
      it_behaves_like "permits for commmunity admins and denies for other admins, users, and billers"
    end

    permissions :edit?, :update? do
      it_behaves_like "permits admins and members of household"

      it "denies access to billers" do
        expect(subject).not_to permit(biller, user.household)
      end
    end

    permissions :accounts? do
      it_behaves_like "permits admins and members of household"

      it "grants access to billers" do
        expect(subject).to permit(biller, user.household)
      end
    end

    permissions :change_community? do
      it_behaves_like "cluster admins only"
    end

    permissions :destroy? do
      shared_examples_for "full denial" do
        it "denies access to admins" do
          expect(subject).not_to permit(admin, household)
        end

        it "denies access to billers" do
          expect(subject).not_to permit(biller, household)
        end
      end

      context "with user" do
        it_behaves_like "full denial"
      end

      context "with assignment" do
        before { household.users.first.assignments.build }
        it_behaves_like "full denial"
      end

      context "with signup" do
        before { household.signups.build }
        it_behaves_like "full denial"
      end

      context "with account" do
        before { household.accounts.build }
        it_behaves_like "full denial"
      end

      context "without any of the above" do
        before { household.users = [] }
        it_behaves_like "permits for commmunity admins and denies for other admins, users, and billers"
      end
    end
  end

  describe "allowed_community_changes" do
    # Class-based auth not allowed
    let(:dummy_household) { Household.new(community: community) }

    before do
      save_policy_objects!(cluster, clusterB, community, communityB, communityX,
        user, admin, cluster_admin, super_admin)
    end

    it "returns empty set for regular users" do
      expect(HouseholdPolicy.new(user, dummy_household).allowed_community_changes.to_a).to eq []
    end

    it "returns own community for admins" do
      expect(HouseholdPolicy.new(admin, dummy_household).allowed_community_changes.to_a).to(
        contain_exactly(community))
    end

    it "returns cluster communities for cluster admins" do
      expect(HouseholdPolicy.new(cluster_admin, dummy_household).allowed_community_changes.to_a).to(
        contain_exactly(community, communityB))
    end

    it "returns all communities for super admins" do
      # This query crosses a tenant boundary so need to do it unscoped.
      ActsAsTenant.unscoped do
        expect(HouseholdPolicy.new(super_admin, dummy_household).allowed_community_changes.to_a).to(
          contain_exactly(community, communityB, communityX))
      end
    end
  end

  describe "ensure_allowed_community_id" do
    let(:params) { {community_id: target_id} }
    let(:policy) { described_class.new(user, Household.new(community: community)) }

    before do
      allow(policy).to receive(:allowed_community_changes).and_return([double(id: 1), double(id: 2)])
      policy.ensure_allowed_community_id(params)
    end

    context "when attempting to set permitted community_id" do
      let(:target_id) { 1 }
      it "should leave community_id param alone" do
        expect(params[:community_id]).to eq 1
      end
    end

    context "when attempting to set unpermitted community_id" do
      let(:target_id) { 3 }
      it "should nullify community_id param" do
        expect(params[:community_id]).to be_nil
      end
    end
  end

  describe "scope" do
    context "normal" do
      before do
        save_policy_objects!(community, communityB, communityX,
          user, other_user, user_in_cluster, outside_user)
      end

      context "for regular user, admin, and cluster admin" do
        it "returns all households in cluster" do
          [user, admin, cluster_admin].each do |actor|
            permitted = HouseholdPolicy::Scope.new(actor, Household.all).resolve
            expect(permitted).to contain_exactly(*[user, other_user, user_in_cluster].map(&:household))
          end
        end
      end

      context "for super admin" do
        it "returns all households" do
          ActsAsTenant.unscoped do
            permitted = HouseholdPolicy::Scope.new(super_admin, Household.all).resolve
            expect(permitted).to contain_exactly(*
              [user, other_user, user_in_cluster, outside_user].map(&:household))
          end
        end
      end

      context "for inactive user" do
        it "returns nothing" do
          permitted = HouseholdPolicy::Scope.new(inactive_user, Household.all).resolve
          expect(permitted).to eq([])
        end
      end
    end

    describe "administerable" do
      let(:scope) { HouseholdPolicy::Scope }
      let!(:cluster) { default_cluster }
      let!(:clusterB) { create(:cluster, name: "Other Cluster") }
      let!(:community) { create(:community, name: "Community A") }
      let!(:communityB) { create(:community, name: "Community B") }
      let!(:communityX) { with_tenant(clusterB) { create(:community, name: "Community X") } }
      let!(:household1) { create(:household, community: community) }
      let!(:household2) { create(:household, community: communityB) }
      let!(:household3) { with_tenant(clusterB) { create(:household, community: communityX) } }
      let(:user) { create(:user, household: household1) }
      let(:admin) { create(:admin, household: household1) }
      let(:cluster_admin) { create(:cluster_admin, household: household1) }
      let(:super_admin) { create(:super_admin, household: household1) }

      it "returns nothing for regular user" do
        expect(scope.new(user, Household.all).administerable.to_a).to eq []
      end

      it "returns households in community for admin" do
        results = scope.new(admin, Household.all).administerable
        expect(results).to contain_exactly(household1)
      end

      it "returns households in cluster for cluster admin" do
        results = scope.new(cluster_admin, Household.all).administerable
        expect(results).to contain_exactly(household1, household2)
      end

      it "returns all households for super admin" do
        # This query crosses a tenant boundary so need to do it unscoped.
        ActsAsTenant.unscoped do
          results = scope.new(super_admin, Household.all).administerable
          expect(results).to contain_exactly(household1, household2, household3)
        end
      end
    end
  end

  describe "permitted attributes" do
    let(:basic_attribs) { [:name, :garage_nums,
      {vehicles_attributes: [:id, :make, :model, :color, :_destroy]},
      {emergency_contacts_attributes: [:id, :name, :relationship, :main_phone, :alt_phone,
        :email, :location, :_destroy]}] }
    let(:admin_attribs) { basic_attribs.concat([:unit_num, :old_id, :old_name, :community_id]) }
    let(:cluster_admin_attribs) { admin_attribs }

    subject { HouseholdPolicy.new(user, household).permitted_attributes }

    context "regular user" do
      it "should allow basic attribs" do
        expect(subject).to contain_exactly(*basic_attribs)
      end
    end

    context "admin" do
      let(:user) { admin }

      it "should allow admin and basic attribs" do
        expect(subject).to contain_exactly(*admin_attribs)
      end
    end

    context "cluster admin" do
      let(:user) { cluster_admin }

      it "should allow all attribs" do
        expect(subject).to contain_exactly(*cluster_admin_attribs)
      end
    end
  end
end
