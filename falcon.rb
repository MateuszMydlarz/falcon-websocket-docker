#!/usr/bin/env -S falcon host
# frozen_string_literal: true

load :rack, :supervisor

rack 'localhost' do
  endpoint Async::HTTP::Endpoint
             .parse('http://0.0.0.0:8013')
end

supervisor