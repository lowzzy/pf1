module Api
  module V1
    class MicropostsController < ApplicationController
      before_action :logged_in_user, only: %i[destroy create]
            before_action :correct_user, only: :destroy

            def create
                @micropost = current_user.microposts.build(micropost_params)
                @micropost.image.attach(params[:micropost][:image])
                if @micropost.save
                    flash[:success] = '投稿が完了しました'
                    redirect_to root_path
                else
                    @feed_items = current_user.feed.paginate(page: params[:page])
                    render 'static_pages/create_micropost'
                end
            end

            def destroy
                @micropost.destroy
                flash[:success] = '投稿が削除されました'
                redirect_to request.referer || root_url
            end

            def search
                @feed_items = Micropost.search(params[:search]) if params[:search].present?
            end

            private

            def micropost_params
                params.require(:micropost).permit(:title, :content, :image, :creater)
            end

            def correct_user
                @micropost = current_user.microposts.find_by(id: params[:id])
                redirect_to root_url if @micropost.nil?
            end
    end
  end
end