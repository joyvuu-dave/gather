class AccountsController < ApplicationController
  load_and_authorize_resource

  def index
    @accounts = @accounts.joins(:household).
      includes(:last_statement, household: [:users, :community]).
      for_community(community).
      where("households.deactivated_at IS NULL OR current_balance >= 0.01").
      by_household_full_name

    @active_accounts = Account.with_activity(community).count
    @no_user_accounts = Account.with_activity_but_no_users(community).count
    @recent_stmt_accounts = Account.with_recent_statement(community).count

    last_statement = Statement.for_community(community).order(:created_at).last
    @last_statement_run = last_statement.try(:created_on)

    @late_fee_count = late_fee_applier.policy? ? late_fee_applier.late_accounts.count : 0

    last_fee = LineItem.joins(:account).
      where(code: "late_fee", accounts: { community_id: community.id }).
      order(:incurred_on).last

    @late_fee_days_ago = last_fee.nil? ? nil : (Date.today - last_fee.incurred_on).to_i
  end

  def apply_late_fees
    late_fee_applier.apply!
    flash[:success] = "Late fees applied."
    redirect_to(accounts_path)
  end

  def apply_payments
    if params[:confirmed]
      Account.find(params[:payment].keys).each{ |a| authorize!(:apply_payments, a) }
      PaymentApplier.new(params[:payment]).apply!
      flash[:success] = "Payments applied."
      redirect_to(accounts_path)
    else
      # Build set of payment hashes to confirm with the user.
      @payments = Account.where(id: params[:payment].reject{ |_, a| a.blank? }.keys).
        by_household_full_name.map do |account|
          { account: account, amount: params[:payment][account.id.to_s] }
      end
    end
  end

  private

  def community
    current_user.community
  end

  def late_fee_applier
    @late_fee_applier ||= LateFeeApplier.new(community)
  end
end