module Sovren
  class Employment
    attr_accessor :employer, :division, :city, :state, :country, :title, :description, :start_date, :end_date, :current_employer

    def self.parse(employment_history)
      return Array.new if employment_history.nil?
      result = employment_history.css('EmployerOrg').collect do |item|
        position = item.css('PositionHistory').first
        e = Employment.new
        e.employer = item.css('EmployerOrgName').text
        e.division = position.css('OrganizationName').text
        e.division = nil if e.employer == e.division
        e.city = item.css('PositionLocation Municipality').text
        e.state = item.css('PositionLocation Region').text
        e.country = item.css('PositionLocation CountryCode').text
        e.title = position.css('Title').text
        e.description = position.css('Description').text
        e.start_date = Date.parse(position.css('StartDate').text) rescue nil
        e.start_date ||= Date.strptime(position.css('StartDate YearMonth').text, "%Y-%m") rescue nil
        e.current_employer = position['currentEmployer'] == "true"

        if e.current_employer
          e.end_date = nil
        else
          e.end_date = Date.parse(position.css('EndDate').text) rescue nil
          e.end_date ||= Date.strptime(position.css('EndDate YearMonth').text, "%Y-%m") rescue nil
        end

        e
      end

      result
    end

    def current_employer?
      !current_employer.nil? && current_employer
    end

  end
end
