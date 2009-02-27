require('rubygems')
require('liquid')
gem('twitter4r', '>= 0.3.0')
require('twitter')

module Pushr
  module Notifier
    # Required gems: twitter4r
    #
    # Sample configuration (add this to your config.yml).
    #
    #   notifiers:
    #     - twitter_notifier:
    #         login: jim
    #         password: xxx
    #         success_template: 'A new revision ({{ repository.info.revision }}) has been pushed: {{ repository.info.message }}'
    #
    # <tt>login</tt> and <tt>password</tt> are required. <tt>success_template</tt> and
    # <tt>failure_template</tt> are optional Liquid (www.liquidmarkup.org) templates with
    # two available variables:
    #
    #   <tt>output</tt>, the output produced by Capistrano
    #   <tt>repository</tt>, a Pushr::Repository
    #
    # <tt>repository</tt> exposes the following fields to your Liquid template:
    #
    #   <tt>revision</tt>, <tt>message</tt>, <tt>author</tt>, <tt>when</tt>, <tt>datetime</tt>
    #
    # Leave a template blank if no tweet should be sent.
    #
    class TwitterNotifier < Base
      attr_accessor :login, :password, :success_template, :failure_template

      def initialize(args)
        validate_args!(args, ['login', 'password'], ['success_template', 'failure_template'])
        @login = args['login']
        @password = args['password']
        @success_template = args['success_template']
        @failure_template = args['failure_template']
      end

      def update(status, output, repository)
        return unless status && @success_template or !status && @failure_template
        log.info '[TwitterNotifier] Sending tweet'
        message = Liquid::Template.parse(status ? @success_template : @failure_template).render('output' => output, 'repository' => repository)
        Twitter::Client.new(:login => login, :password => password).status(:post, message)
      end
    end
  end
end