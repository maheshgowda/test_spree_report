module Spree
  module Api
    class SpreeReportsController < Spree::Api::BaseController
      before_filter :requires_admin

      def orders_by_period
        @report = SpreeReports::Reports::OrdersByPeriod.new(params)
        render json: @report.data
      end
      
      def sold_products
        @report = SpreeReports::Reports::SoldProducts.new(params)
        render json: @report.data
      end
      
      private
        def requires_admin
          return if @current_user_roles.include?(SpreeReports.api_user_role)
          unauthorized and return
        end
        
    end
  end
end