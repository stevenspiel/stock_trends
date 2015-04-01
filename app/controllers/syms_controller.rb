class SymsController < ApplicationController
  include SymsHelper

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

  def favorites
    @syms = Sym.favorited.paginate(page: params[:page], per_page: 10)
    build_charts(@syms)
  end


  def toggle_favorite
    @sym = Sym.find(params[:id])
    @sym.update_column(:favorite, !@sym.favorite)
  end

  def index
    session[:search_results] = request.url
    @q = Sym.ransack(params[:q])
    @syms = @q.result.successful_intraday.enabled.paginate(page: params[:page], per_page: 10)
    build_charts(@syms)
  end

  def show
    @sym = Sym.find(params[:id])
    @sym.week_charts = week_day_charts(@sym) << past_n_days_chart(@sym)
    @sym.historical_chart = historical_chart(@sym)
  end

  def destroy
    Sym.find(params[:id]).update_column(:disabled, true)
    render nothing: true
  end

  def rerun_historical
    sym = Sym.find(params[:id])
    api = Api.find(params[:api_id])
    sym.historical_datums.each(&:destroy)
    api.model_class.to_s.constantize.new.log_historical(sym)
    redirect_to sym_path(sym)
  end

  def build_charts(syms)
    syms.each do |sym|
      sym.week_charts = week_day_charts(sym) << past_n_days_chart(sym)
      sym.historical_chart = historical_chart(sym)
    end
  end

end
