class SubmissionsController < ApplicationController

    before_action :find_submission, only: [:show, :update, :destroy]

    def index
        @submissions = @current_user.submissions
        s3 = Aws::S3::Client.new(
            region: ENV['AWS_REGION'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
        @submissions.each do |submission|
            submission.image_url = 'heheeee'
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
end
