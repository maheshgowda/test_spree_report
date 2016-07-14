module SpreeReports
  class Helper
    
    def self.divide(a, b)
      return nil if b == 0
      a / b
    end

    def self.round(a)
      return a.round(2) if a
      a
    end

    def self.date_formatted(date, group_by)
      date_format = SpreeReports.date_formats[group_by]
      date.strftime(date_format)
    end
    
  end
end