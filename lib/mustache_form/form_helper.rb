require 'mustache'
#
# When the Mustache variable is a callable object, such as a function or lambda, the
# object will be invoked and passed the block of text. hence we then yield to the
# standard ruby form_for to build our form and then have Mustache render each key value pair
module MustacheForm
  module FormHelper

    def mustache_form_tag(url = nil, html = nil)
      if MustacheForm::FormHelper::SIMPLE_FORM_ENABLED
        form_helper_method = :simple_form_tag
      else
        form_helper_method = :form_tag
      end
      lambda do |text|
        send(form_helper_method, url: url, html: html) do |f|
          obj = FormedMustache.new(yield(f))
          Mustache.render(text, obj).html_safe
        end
      end
    end

    def mustache_form_for(object, url = nil, html = nil)
      if MustacheForm::FormHelper::SIMPLE_FORM_ENABLED
        form_helper_method = :simple_form_for
      else
        form_helper_method = :form_for
      end
      lambda do |text|
        send(form_helper_method, object, url: url, html: html) do |f|
          obj = FormedMustache.new(yield(f))
          Mustache.render(text, obj).html_safe
        end
      end
    end

    def self.included(base)
      base.class_eval do
        alias_method :custom_form_tag, :mustache_form_tag
        alias_method :custom_form_for, :mustache_form_for
      end
    end

  end

  class FormedMustache < Mustache
    def initialize(data)
      data.each_pair do |key, value|
        FormedMustache.send(:define_method, key, proc{value})
      end
    end

    def escapeHTML(str)
      str
    end
  end
end
