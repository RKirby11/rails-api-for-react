class SubmissionsController < ApplicationController

    before_action :find_submission, only: [:show, :update, :destroy]

    def index
        page = params[:page].to_i || 1
        per_page = params[:per_page].to_i || 6

        if valid_page?(page) && valid_per_page?(per_page)
            @submissions = @current_user.submissions
                                    .includes(:daily_word)
                                    .limit(per_page)
                                    .offset((page - 1) * per_page)
                                    .to_a

            @submissions = @submissions.map do |submission|
                {
                    'image_url': submission.presigned_image_url,
                    'word': submission.daily_word.word,
                    'date': submission.daily_word.date,
                    'note': submission.note
                }
            end
            render json: @submissions, status: :ok
        else
            render json: { error: 'Invalid page or perPage parameter' }, status: :bad_request
        end        
    end

    def show
        render json: @submission, status: 200
    end

    def create
        @todays_word = DailyWord.find_by(date: Date.today.beginning_of_day)
        @submission = @current_user.submissions.build(submission_params.merge(:daily_word => @todays_word))
        if @submission.save
            render json: @submission, status: :created
        else
            render json: { error: @submission.errors.full_messages }, status: :service_unavailable
        end
    end

    def destroy
        if @submission.destroy
            render json: { message: "Submission deleted" }, status: :no_content
        else
            render json: { error: @submission.errors.full_messages }, status: :service_unavailable
        end
    end

    private
        def find_submission
            @submission = Submission.find(params[:id])
        rescue ActiveRecord::RecordNotFound => e
            render json: { error: 'Submission not found' }, status: :not_found
        end

        def submission_params
            params.require(:submission).permit(:image_url, :note)
        end

        def valid_page?(page)
            page.is_a?(Integer) && page > 0
        end

        def valid_per_page?(per_page)
            per_page.is_a?(Integer) && per_page > 0
        end
end
