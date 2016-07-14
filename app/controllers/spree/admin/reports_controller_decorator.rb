Spree::Admin::ReportsController.class_eval do
  before_filter :spree_reports_setup, only: [:index]
  require "spree_report/reports/base"
  require "spree_report/reports/orders_by_period"
  require "spree_report/reports/sold_products"
  require "chartkick"
  require "groupdate" 
  
  def orders_by_period
    @report = SpreeReports::Reports::OrdersByPeriod.new(params)
    respond_to do |format|
      format.html
      format.csv {
        return head :unauthorized unless SpreeReports.csv_export
        send_data @report.to_csv, filename: @report.csv_filename, type: "text/csv"
      }
    end 
  end
  
  def sold_products
    @report = SpreeReports::Reports::SoldProducts.new(params)
    respond_to do |format|
      format.html
      format.csv {
        return head :unauthorized unless SpreeReports.csv_export
        send_data @report.to_csv, filename: @report.csv_filename, type: "text/csv"
      }
    end 
  end

  protected

  def spree_reports_setup
    SpreeReports.reports.each do |report|
      Spree::Admin::ReportsController.add_available_report! report
    end
  end
  
end