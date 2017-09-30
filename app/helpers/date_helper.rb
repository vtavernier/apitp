module DateHelper
  include ActionView::Helpers::DateHelper

  def render_date(date, reference = DateTime.now, reference_name = nil)
    # Compute time diff in words
    time_diff = distance_of_time_in_words(date, reference)

    # Add reference name
    if reference_name
      if date >= reference
        time_diff = t('date_helper.after', diff: time_diff, reference: reference_name)
      else
        time_diff = t('date_helper.before', diff: time_diff, reference: reference_name)
      end
    else
      if date >= reference
        time_diff = t('date_helper.in', diff: time_diff)
      else
        time_diff = t('date_helper.ago', diff: time_diff)
      end
    end

    # Format
    "#{l(date, format: :long)} (#{time_diff})"
  end
end
