module DateHelper
  def render_date(date, reference = DateTime.now, reference_name = nil)
    # Compute time diff in words
    time_diff = distance_of_time_in_words(date, reference)

    # Add reference name
    if reference_name
      if date >= reference
        time_diff = "#{time_diff} after #{reference_name}"
      else
        time_diff = "#{time_diff} before #{reference_name}"
      end
    else
      if date >= reference
        time_diff = "in #{time_diff}"
      else
        time_diff = "#{time_diff} ago"
      end
    end

    # Format
    "#{l(date, format: :long)} (#{time_diff})"
  end
end
