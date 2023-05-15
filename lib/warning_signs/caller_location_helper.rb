module WarningSigns
  module CallerLocationHelper
    def caller_locations_filtered
      caller_locations.reject do |location|
        ignore_line(location.to_s)
      end
    end

    def ignore_line(line)
      line.include?("<internal:") ||
        line.include?("warning_signs/lib") ||
        line.include?("warning_signs/spec")
    end
  end
end
