module RunnersHelper
  def runner_status_icon(runner)
    unless runner.contacted_at
      return content_tag :i, nil,
        class: "icon-warning-sign",
        title: "New runner. Has not connected yet"
    end

    status =
      if runner.active?
        runner.contacted_at > 3.hour.ago ? :online : :offline
      else
        :paused
      end

    content_tag :i, nil,
      class: "icon-circle runner-status-#{status}",
      title: "Runner is #{status}, last contact was #{time_ago_in_words(runner.contacted_at)} ago"
  end
end
