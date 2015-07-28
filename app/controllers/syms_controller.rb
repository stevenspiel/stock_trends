class SymsController < ApplicationController
  include SymsHelper
  include ChartsHelper

  def autocomplete
    results = Market.by_importance.map do |market|
      children = market.syms.where('name ilike ?', "%#{params[:search_term]}%").order(:name).limit(10).map(&:as_json)
      next unless children.any?
      { text: market.to_s, children: children }
    end.compact

    respond_to do |format|
      format.html
      format.json { render json: results }
    end
  end

  def initialize_autocomplete
    ids = params[:ids].split(',')
    @syms = Sym.where(id: ids)

    respond_to do |format|
      format.html
      format.json { render json: @syms }
    end
  end

  def favorites
    @syms = Sym.favorited.enabled.paginate(page: params[:page], per_page: 10)
    build_charts(*@syms)
  end

  def toggle_favorite
    @sym = Sym.find(params[:id])
    favorite_sym = FavoriteSym.where(user: current_user, sym: @sym).first_or_initialize
    if favorite_sym.new_record?
      @favorited = favorite_sym.save!
    else
      favorite_sym.destroy
      @favorited = false
    end
  end

  def disable
    raise Consul::Powerless unless current_user.admin?
    sym = Sym.find(params[:id])
    sym.update_attribute(:disabled, true)
    render nothing: true
  end

  def index
    session[:search_results] = request.url
    transform_search_params!
    @q = Sym.ransack(params[:q])
    @syms = @q.result.enabled.ordered.paginate(page: params[:page], per_page: 10)
    build_charts(*@syms)
  end

  def show
    @sym = Sym.find(params[:id])
    build_charts(@sym)
  end

  private

  def build_charts(*syms)
    syms.each do |sym|
      relevant_ticks = sym.cached(:five_weeks)
      sym.week_charts = [*week_day_charts(relevant_ticks), past_n_days_chart(relevant_ticks, 5)]
      sym.historical_chart = historical_chart(sym.cached(:historical_data), sym)
    end
  end

  def transform_search_params!
    _ins = params.fetch(:q, {}).keys.select{|key| key.to_s[-3..-1] == '_in'}
    _ins.each { |key| params[:q][key] = params[:q][key].to_s.split(',') }
  end
end
