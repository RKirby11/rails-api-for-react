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
            render json: @submissions, status: 200
        else
            render json: { error: 'Invalid page or perPage parameter' }, status: 400
        end        
    end

    def show
        render json: @submission, status: 200
    end

    def create
        @todays_word = DailyWord.where(date: Date.today.beginning_of_day).first
        @submission = @current_user.submissions.build(submission_params.merge(:daily_word => @todays_word))
        if @submission.save
            render json: @submission, status: 201
        else
            render json: { error: @submission.errors.full_messages }, status: 503
        end
    end

    def destroy
        unless @submission.destroy
            render json: { error: @submission.errors.full_messages }, status: 503
        end
    end

    private
        def find_submission
            @submission = Submission.find(params[:id])
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
