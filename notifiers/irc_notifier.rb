require 'rubygems'
require('liquid')
require 'shout-bot'

module Pushr
  module Notifier
    # Required gems: shout-bot (sr-shout-bot @ github.com)
    #
    # Sample configuration (add this to your config.yml).
    #
    #   notifiers:
    #     - irc_notifier:
    #         uri: 'irc://irc.freenode.net:6667/test'
    #         as: Jim
    #         success_template: 'A new revision ({{ repository.revision }}) has been pushed: {{ repository.message }}'
    #
    # <tt>uri</tt> is required. <tt>as</tt> is the optional name to send the message as,
    # and <tt>success_template</tt> and <tt>failure_template</tt> are optional Liquid
    # (www.liquidmarkup.org) templates with two available variables:
    #
    #   <tt>output</tt>, the output produced by Capistrano
    #   <tt>repository</tt>, a Pushr::Repository
    #
    # <tt>repository</tt> exposes the following fields to your Liquid template:
    #
    #   <tt>revision</tt>, <tt>message</tt>, <tt>author</tt>, <tt>when</tt>, <tt>datetime</tt>
    #
    # Leave a template blank if no message should be sent.
    #
    class IrcNotifier < Base
      attr_accessor :uri, :as, :success_template, :failure_template

      def initialize(args)
        validate_args!(args, ['uri'], ['as', 'success_template', 'failure_template'])
        @uri = args['uri']
        @as = args['as'] || 'Pushr'
        @success_template = args['success_template']
        @fail_template = args['failure_template']
      end

      def update(status, output, repository)
        return unless status && @success_template or !status && @failure_template
        log.info "[IrcNotifier] Sending message to #{@uri}"
        message = Liquid::Template.parse(status ? @success_template : @failure_template).render('output' => output, 'repository' => repository)
        ShoutBot.shout(@uri, :as => @as) { |channel| channel.say message }
      end
    end
  end
end