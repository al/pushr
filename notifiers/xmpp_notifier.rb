require 'rubygems'
require('liquid')
require 'xmpp4r'

module Pushr
  module Notifier
    # Required gems: xmpp4r
    #
    # Sample configuration (add this to your config.yml).
    #
    #   notifiers:
    #     - xmpp_notifier:
    #         login: jim@mail.com
    #         password: xxx
    #         recipients:
    #           - bill@mail.com
    #           - sarah@mail.com
    #         success_template: 'A new revision ({{ repository.revision }}) has been pushed: {{ repository.message }}'
    #
    # <tt>login</tt>, <tt>password</tt> and <tt>recipients</tt> are required. <tt>success_template</tt>
    # and <tt>failure_template</tt> are optional Liquid (www.liquidmarkup.org) templates with two
    # available variables:
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
    class XmppNotifier < Base
      attr_accessor :login, :password, :recipients, :success_template, :failure_template

      def initialize(args)
        validate_args!(args, ['login', 'password', 'recipients'], ['success_template', 'failure_template'])
        @login = args['login']
        @password = args['password']
        @recipients = args['recipients']
        @success_template = args['success_template']
        @fail_template = args['failure_template']
      end

      def update(status, output, repository)
        return unless status && @success_template or !status && @failure_template
        client = Jabber::Client.new(Jabber::JID.new(@login))
        client.connect
        client.auth(password)
        client.send(Jabber::Presence.new.set_status("Pushr at #{Time.now.utc}"))
        message = Liquid::Template.parse(status ? @success_template : @failure_template).render('output' => output, 'repository' => repository)
        @recipients.each do |recipient|
          log.info "[XmppNotifier] Sending message to #{recipient}"
          client.send(Jabber::Message.new(recipient, message).set_type(:normal))
        end
        client.close
      end
    end
  end
end