class ArticlesController < ApplicationController
  inherit_resources
  actions :index, :create, :new
  respond_to :html

  layout :layout_by_action

  def index
    @sticky_articles = Article.sticky
    index!
  end

  private

  def layout_by_action
    if %(create new).include? action_name
      "editing"
    else
      "application"
    end
  end

end
