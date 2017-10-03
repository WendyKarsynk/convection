module Admin
  class SubmissionsController < ApplicationController
    before_action :set_submission, only: [:show, :edit, :update]
    before_action :set_pagination_params, only: [:index]

    def index
      @counts = Submission.group(:state).count
      @completed_submissions_count = Submission.completed.count
      @filters = { state: params[:state] }

      @submissions = params[:state] ? Submission.where(state: params[:state]) : Submission.completed
      @submissions = @submissions.order(id: :desc).page(@page).per(@size)
    end

    def new
      @submission = Submission.new
    end

    def create
      @submission = Submission.new(submission_params.merge(state: 'submitted'))
      if @submission.save
        redirect_to admin_submission_path(@submission)
      else
        render 'new'
      end
    end

    def show
      @notified_partner_submissions = @submission.partner_submissions.where.not(notified_at: nil)
      partners = @notified_partner_submissions.map(&:partner)
      return unless partners && !partners.empty?
      partners_details_response = Gravql::Schema.execute(
        query: GravqlQueries::PARTNER_DETAILS_QUERY,
        variables: { ids: partners.pluck(:gravity_partner_id) }
      )
      flash.now[:error] = 'Error fetching some partner details.' if partners_details_response[:errors].present?
      @partner_details = partners_details_response[:data][:partners].map { |pd| [pd[:id], pd] }.to_h
    end

    def edit; end

    def update
      if SubmissionService.update_submission(@submission, submission_params, @current_user)
        redirect_to admin_submission_path(@submission)
      else
        render 'edit'
      end
    end

    def match_artist
      if params[:term]
        @term = params[:term]
        @artists = Gravity.client.artists(term: @term).artists
      end
      respond_to do |format|
        format.json { render json: @artists || [] }
      end
    end

    def match_user
      if params[:term]
        @term = params[:term]
        @users = Gravity.client.users(term: @term).users
      end
      respond_to do |format|
        format.json { render json: @users || [] }
      end
    end

    private

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def submission_params
      params.require(:submission).permit(
        :artist_id,
        :authenticity_certificate,
        :category,
        :depth,
        :dimensions_metric,
        :edition_number,
        :edition_size,
        :height,
        :location_city,
        :location_country,
        :location_state,
        :medium,
        :primary_image_id,
        :provenance,
        :signature,
        :state,
        :title,
        :user_id,
        :width,
        :year
      )
    end
  end
end