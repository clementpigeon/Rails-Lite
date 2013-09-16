require 'uri'

class Params
  attr_reader :params

  def initialize(req, route_params)
    @params = {}
    query_string = req.query_string
    if query_string
      @params.merge!(parse_post_encoded_form(query_string))
    end
    if req.body
      @params.merge!(parse_post_encoded_form(req.body))
    end
  end

  def [](key)
  end

  def to_s
  end

  private
  # def parse_www_encoded_form(www_encoded_form)
  #   queries = URI.decode_www_form(www_encoded_form)
  #   result = {}
  #   queries.each do |query|
  #     result[query.first] = query.last
  #   end
  #   result
  # end


  def parse_key(key)
  end

  def find_key(string)

  end

  def parse_www_encoded_form(www_encoded_form)
    queries = URI.decode_www_form(www_encoded_form)
    result = {}
    queries.each do |query|
      result[query.first] = query.last
    end
    result
  end

  def parse_post_encoded_form(post_encoded_form)
    string = parse_www_encoded_form(post_encoded_form).to_s

    string = string[1..-2]
    regexp = Regexp.new('\]\[|\[|\]')

    components = string.split(regexp)
    p components
    keys = [[components.first[1..-1]]]
    i = 0

    components[1..-1].each do |component|
      p component
      if component[0..2] == "\"=>"
        # p 'route 1'
        split = component.split('"')
        keys[i] << split[2]
        i += 1
        keys[i] = [split[4]]
      elsif component[0] == '"'
        # p 'route 2'
        keys[i] = [component[1..-1]]
      else
        # p 'route 3'
        keys[i] << component
      end
    end
    p keys[0..-2]
    create_object(keys[0..-2])

  end

  def create_object(keys)
    object = {}
    if keys.first.is_a?(String)
      if keys.length > 2
        object[keys[0]] = create_object(keys[1..-1])
      else
        object[keys[0]] = keys[1]
      end
    end
    if keys.first.is_a?(Array)
      return create_object(keys.first) if keys.count == 1
      p 'yeah'
      p create_object(keys.first)
      p (create_object(keys[1..-1]))
      return deep_merge(create_object(keys.first), (create_object(keys[1..-1])))
    end
    object
  end

  def deep_merge(hash1, hash2)
    hash1.merge(hash2) do |key, val1, val2|
      if val1.is_a?(Hash) && val2.is_a?(Hash)
        deep_merge(val1, val2)
      else
        val1.merge!(val2)
      end
    end
  end

end

