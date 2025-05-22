module SqlCounter
  def count_sql_queries(&block)
    count = 0
    callback = ->(_name, _start, _fin, _id, payload) do
      count += 1 if payload[:sql] !~ /SAVEPOINT|RELEASE SAVEPOINT|BEGIN/
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &block)
    count
  end
end

RSpec.configure { |c| include SqlCounter }