class SubmissionsController < ApplicationController

    before_action :find_submission, only: [:show, :update, :destroy]

    def index
        page = params[:page].to_i || 1
        per_page = params[:per_page].to_i || 6

        if !valid_page?(page) || !valid_per_page?(per_page)
            render json: { error: 'Invalid page or perPage parameter' }, status: 400
            return
        end

        @submissions = @current_user.submissions
                                    .limit(per_page)
                                    .offset((page - 1) * per_page)
                                    .to_a
        @submissions.map do |submission|
            submission.image_url = submission.presigned_image_url
            submission.word = 'test'
            submission
        end
        render json: @submissions, status: 200
    end

    def show
        render json: @submission, status: 200
    end

    def create
        @submission = @current_user.submissions.build(submission_params.merge(:date => Date.today))
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
            params.require(:submission).permit(:image_url, :note, :word)
        end
        def valid_page?(page)
            page.is_a?(Integer) && page > 0
        end
        def valid_per_page?(per_page)
            per_page.is_a?(Integer) && per_page > 0
        end
end
