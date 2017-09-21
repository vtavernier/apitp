module DateHelper
  def self.school_year(date = Date.today)
    if date.month <= 7
      date.year - 1
    else
      date.year
    end
  end
end