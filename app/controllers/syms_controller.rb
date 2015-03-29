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

  def historical
    @syms = Sym.successful_historical.limit(1)
    @syms.each{ |sym| sym.charts = [historical_chart(sym)] }
  end

  def index
    session[:search_results] = request.url
    @q = Sym.ransack(params[:q])
    @syms = @q.result.successful_intraday.paginate(page: params[:page], per_page: 10)
    @syms.each do |sym|
      sym.week_charts = week_day_charts(sym) << past_n_days_chart(sym)
      sym.historical_chart = historical_chart(sym)
    end
  end

  def show
    @sym = Sym.find(params[:id])
    @sym.week_charts = week_day_charts(@sym) << past_n_days_chart(@sym)
    @sym.historical_chart = historical_chart(@sym)
  end

  def destroy
    Sym.find(params[:id]).destroy
    render nothing: true
  end

  def rerun_historical
    sym = Sym.find(params[:id])
    api = Api.find(params[:api_id])
    sym.historical_datums.each(&:destroy)
    api.model_class.to_s.constantize.new.log_historical(sym)
    redirect_to sym_path(sym)
  end

end
