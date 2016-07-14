module SpreeReports
  module Reports
    class SoldProducts < SpreeReports::Reports::Base
      
      attr_accessor :params, :data, :orders
      attr_accessor :currencies, :currency, :stores, :store, :months, :date_start
      
      def initialize(params)
        @params = params
        setup_params
        get_data
        build_response
      end
      
      def setup_params
        @currencies = Spree::Order.select('currency').distinct.map { |c| c.currency }  
        @currency = @currencies.include?(params[:currency]) ? params[:currency] : @currencies.first
        
        @stores = Spree::Store.all.map { |store| [store.name, store.id] }
        @stores << ["all", "all"]
        @store = @stores.map{ |s| s[1].to_s }.include?(params[:store]) ? params[:store] : @stores.first[1]
    
        @months = SpreeReports.report_months.include?(params[:months]) ? params[:months] : SpreeReports.default_months.to_s
        @date_start = (@months != "all") ? (Time.now - (@months.to_i).months) : nil       
      end
      
      def get_data
        @orders = Spree::Order.complete.where(payment_state: 'paid')
        @orders = @orders.where("completed_at >= ?", @date_start) if @date_start
        @orders = @orders.where(currency: @currency) if @currencies.size > 1
        @orders = @orders.where(store_id: @store) if @stores.size > 2 && @store != "all"
        @orders = without_excluded_orders(@orders)
        
        order_ids = @orders.pluck(:id)
        line_items = Spree::LineItem.where(order_id: order_ids)
        variant_ids_and_quantity = line_items.group(:variant_id).sum(:quantity).sort_by { |k,v| v }.reverse
        
        variants = Spree::Variant.all
        variant_names = variants.all.map { |v| [v.id, [variant_name_with_option_values(v), v.slug, v.available_on] ] }.to_h
        
        @data_tmp = variant_ids_and_quantity.map do |id, quantity|
          [
            id,
            quantity,
            variant_names[id][0],
            variant_names[id][1],
            variant_names[id][2]
          ]
        end
      end
      
      def build_response
        @data = @data_tmp.map do |item|
          {
            variant_id: item[0],
            variant_name: item[2],
            variant_slug: item[3],
            variant_available_on: item[4],
            quantity: item[1]
          }
        end
      end
      
      def variant_name_with_option_values(v)
        s = v.name
        option_values = v.option_values.map { |o| o.presentation }
        s += " (#{option_values.join(", ")})" if option_values.any?
        s
      end
        
      def to_csv
    
        CSV.generate(headers: true, col_sep: ";") do |csv|
          csv << %w{ variant_id variant_name variant_slug quantity }
      
          @data.each do |item|
            csv << [
              item[:variant_id],
              item[:variant_name],
              item[:variant_slug],
              item[:quantity]
            ]
          end
      
        end
    
      end
      
      def csv_filename
        "sold_products_#{@months}-months.csv"
      end
      
    end
  end
end