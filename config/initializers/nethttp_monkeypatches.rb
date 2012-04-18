module Net
  class HTTP
    old_begin_transport = instance_method(:begin_transport)
    old_end_transport = instance_method(:end_transport)

    define_method(:begin_transport) do |req|
      old_begin_transport.bind(self).(req)
      @@request_response_time = Time.now
    end

    define_method(:end_transport) do |req, res|
      @@request_response_time = Time.now - @@request_response_time
      old_end_transport.bind(self).(req, res)
    end

    def self.last_response_time
      @@request_response_time.to_f
    end

    class Persistent
      define_method(:last_response_time) do
        HTTP.last_response_time
      end
    end
  end
end
