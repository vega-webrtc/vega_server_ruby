VegaServer::MessageSteps = RSpec::EM.async_steps do
  include VegaServer::SetupTeardownSteps

  def add_to_room(client_id, client_info, &callback)
    EM.next_tick do
      storage = VegaServer.storage
      storage.add_to_room(client_id, client_info)
    end

    EM.next_tick(&callback)
  end

  def stub_client_id(client_id, &callback)
    @client_id = client_id

    EM.add_timer 0.1 do
      SecureRandom.stubs(:uuid).returns client_id
      EM.next_tick(&callback)
    end
  end

  def add_listener(client, &callback)
    EM.next_tick do
      ws = instance_variable_get "@#{client}"

      ws.on :message do |event|
        messages = instance_variable_get "@#{client}_messages"

        messages ||= []
        messages.push event.data

        instance_variable_set "@#{client}_messages", messages
      end

      callback.call
    end
  end

  def send_message(client, message, &callback)
    EM.add_timer 0.1 do
      ws = instance_variable_get "@#{client}"
      ws.send(message)
      EM.next_tick(&callback)
    end
  end

  def assert_connection_in_pool(&callback)
    EM.add_timer 0.1 do
      ws = VegaServer.connection_pool[@client_id]
      expect(ws).to_not be_nil
      EM.next_tick(&callback)
    end
  end

  def refute_connection_in_pool(&callback)
    EM.add_timer 0.1 do
      ws = VegaServer.connection_pool[@client_id]
      expect(ws).to be_nil
      EM.next_tick(&callback)
    end
  end

  def assert_client_in_room(room_id, client_id, &callback)
    EM.add_timer 0.1 do
      storage = VegaServer.storage

      if room = storage.room(room_id)
        expect(storage.badge(client_id)).to_not be_nil
        expect(storage.client_room(client_id)).to eq room
      else
        fail 'room does not exist'
      end

      EM.next_tick(&callback)
    end
  end

  def refute_client_in_room(room_id, client_id, &callback)
    EM.add_timer 0.1 do
      storage = VegaServer.storage

      if room = storage.room(room_id)
        expect(storage.badge(client_id)).to be_nil

        room_client_ids = room.map { |client| client[:client_id] }
        expect(room_client_ids).to_not include client_id
      end

      EM.next_tick(&callback)
    end
  end

  def assert_response(client, response, &callback)
    EM.add_timer 0.1 do
      messages = instance_variable_get "@#{client}_messages"
      expect(messages).to include response
      callback.call
    end
  end

  def refute_response(client, response, &callback)
    EM.add_timer 0.1 do
      messages = instance_variable_get("@#{client}_messages") || []
      expect(messages).to_not include response
      callback.call
    end
  end
end
