class ReservationsController < ApplicationController
  def index
    authorize Reservation::Reservation
    @reservations = policy_scope(Reservation::Reservation)
  end

  def new
    @resource = Reservation::Resource.find_by(id: params[:resource])
    raise "Resource not found" unless @resource

    @reservation = Reservation::Reservation.new_with_defaults(@resource)
    authorize @reservation
    prep_form_vars
  end

  def create
    @reservation = Reservation::Reservation.new(reserver: current_user)
    @reservation.assign_attributes(reservation_params)
    authorize @reservation
    if @reservation.save
      flash[:success] = "Reservation created successfully."
      redirect_to reservations_path
    else
      @resource = @reservation.resource
      prep_form_vars
      set_validation_error_notice
      render :new
    end
  end

  private

  def prep_form_vars
    @kinds = @resource.kinds # May be nil
  end

  # Pundit built-in helper doesn't work due to namespacing
  def reservation_params
    params.require(:reservation_reservation).permit(policy(@reservation).permitted_attributes)
  end
end
