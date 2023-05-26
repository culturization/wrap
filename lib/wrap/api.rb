module Wrap
  module API
    API_BASE = 'https://discord.com/api/v10/'

    def api_call(method, path, rl_key = nil, data = nil)
      rl = @ratelimits[rl_key]

      if rl && rl[:reset] > Time.now && rl[:remaining] == 0
        LOGGER.error("Ratelimit exceeded, key: #{rl_key}")
        raise RateLimitError.new(rl)
      end

      res = raw_api_call(method, path, token, data)

      @ratelimits[rl_key] = {
        remaining: res['X-RateLimit-Remaining'],
        reset: Time.at(res['X-Ratelimit-Reset'].to_i)
      }

      json = JSON.parse(res.body) if res.body

      if res.is_a?(Net::HTTPSuccess)
        json
      else
        raise Errors.find_err(json['message'], json['code'])
      end
    end

    def raw_api_call(method, path, token, data)
      uri = URI.join(API_BASE, path)

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      req = Net::HTTP.const_get(method).new(
        uri,
        'Authorization' => @token, 'Content-Type' => 'application/json'
      )
      req.body = data.to_json if data

      http.request(req)
    end
  end
end