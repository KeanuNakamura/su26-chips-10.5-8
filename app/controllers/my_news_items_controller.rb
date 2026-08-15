# frozen_string_literal: true

class MyNewsItemsController < ApplicationController
  before_action :require_login!

  before_action :set_representative
  before_action :set_representatives_list
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @issue = params[:issue]
  end

  def search
    @issue = params[:issue].to_s.strip

    if @issue.blank?
      redirect_to representative_new_my_news_item_path(@representative),
                  alert: 'Choose an issue to search for.'
      return
    end

    @articles = currents_articles_for(@issue)
  end

  def edit; end

  def create
    article = selected_article

    if article.blank?
      redirect_to search_results_path, alert: 'Choose an article to save.'
      return
    end

    @news_item = @representative.news_items.new(
      title:       article[:title],
      link:        article[:url],
      description: article[:description],
      issue:       params[:issue]
    )

    if @news_item.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      redirect_to search_results_path, alert: 'Unable to save that article.'
    end
  end

  def update
    if @news_item.update(news_item_params)
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News was successfully destroyed.'
  end

  private


  def selected_article
    url = params[:article_url].to_s
    return if url.blank?

    articles = params.permit(articles: %i[title description url])[:articles]
    return if articles.blank?

    match = articles.to_h.values.find { |attrs| attrs['url'] == url }
    match&.with_indifferent_access
  end

  def search_results_path
    representative_search_my_news_item_path(@representative, issue: params[:issue])
  end
  
  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :issue, :description, :link, :representative_id)
  end

  def currents_articles_for(issue)
    return [] if issue.blank?

    api_key = ENV.fetch('CURRENTS_API_KEY', Rails.application.credentials.dig(:CURRENTS_API_KEY))
    CurrentsClient.new(api_key).search_by_issue(issue)
  rescue ArgumentError, CurrentsClient::Error, Faraday::Error
    flash.now[:alert] = 'Unable to fetch news articles. Please try again.'
    []
  end
end
