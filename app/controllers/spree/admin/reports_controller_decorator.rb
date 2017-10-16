Spree::Admin::ReportsController.class_eval do
  before_action :advanced_reporting_setup, only: [:index]
  before_action :date_filters, only: [:out_of_stock]

  def advanced_reporting_setup
    Spree::Admin::ReportsController.add_available_report! :out_of_stock
  end

  def out_of_stock
    @movements_out_of_stock = []
    Spree::Variant.all.each do |variant|
      movements = has_stock_between(variant, @from_date, @to_date)
      @movements_out_of_stock << {variant: variant, movements: movements} if movements.present?
    end
  end

  private

  def has_stock_between(variant, from, to)
    without_stock_movements = []
    variant.stock_items.each do |si|
      outside_range_until_today = si.stock_movements.where('created_at > ?', to).sum(&:quantity)
      end_of_range_stock = variant.total_on_hand + outside_range_until_today

      # Calculating if stock was zero in range
      temp_stock = end_of_range_stock
      si.stock_movements.where(created_at: from..to).each do |mov|
        temp_stock += mov.quantity
        if temp_stock <= 0
          without_stock_movements << mov
        end
      end
    end
    without_stock_movements
  end

  def date_filters
    begin
      @from_date = Time.zone.parse(params[:created_at_gt].to_s).beginning_of_day
    rescue
      @from_date = Time.zone.now.beginning_of_month
    end
    begin
      @to_date = Time.zone.parse(params[:created_at_lt].to_s).end_of_day
    rescue
      @to_date = Time.zone.now.end_of_month
    end

    @from_date ||= Time.zone.now.beginning_of_month #default
    @to_date ||= Time.zone.now.end_of_month #default
  end
end