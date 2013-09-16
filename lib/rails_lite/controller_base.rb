require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @request = req
    @response = res
    @params = Params.new(req, route_params).params
    @already_built_response = false
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    raise 'already rendered' if already_rendered?
    @response.status = 302
    @response.header['location'] = url
    @already_built_response = true
    session.store_session(@response)
  end

  def render_content(content, type)
    raise 'already rendered' if already_rendered?
    @response.content_type = type
    @response.body = content
    @already_built_response = true
    session.store_session(@response)
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb_template = ERB.new(template).result(binding)
    render_content(erb_template, 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
