require 'spec_helper'

describe 'call message is received' do
  include VegaServer::MessageSteps

  let(:client) { 'client' }
  let(:message) { MultiJson.dump(raw_message) }
  let(:raw_message) { { type: 'call', payload: payload } }
  let(:payload) { { roomId: room_id, badge: badge } }
  let(:room_id) { '/chat/abc123' }
  let(:badge) { {} }
  let(:client_id) { 'yup' }

  after { stop_server }

  shared_examples_for 'successful call message' do
    it 'adds the connection to the pool' do
      send_message(client, message)
      assert_connection_in_pool
    end

    it 'adds the client to the room' do
      send_message(client, message)
      assert_client_in_room(room_id, client_id)
    end
  end

  describe 'with call middleware' do
    class TestCallMiddleware
      def initialize(client_caller)
        @client_caller = client_caller
      end

      def call
        @client_caller.reject_response('an error occurred')
      end
    end

    let(:response) do
      MultiJson.dump({ type: 'callRejected',
                       payload: { error: 'an error occurred' } })
    end

    before do
      set_call_middlewares([TestCallMiddleware])
      start_server
      open_socket(client)
      stub_client_id(client_id)
    end

    after do
      reset_call_middlewares
    end

    it 'runs the call through the middleware' do
      add_listener(client)
      send_message(client, message)
      assert_response(client, response)
    end
  end

  describe 'no call middleware' do
    before do
      start_server
      open_socket(client)
      stub_client_id(client_id)
    end

    context 'room is empty' do
      let(:response) do
        MultiJson.dump({ type: 'callAccepted',
                         payload: { peers: [] } })
      end

      it_should_behave_like 'successful call message'

      it 'sends a `callAccepted` response with no peerIds' do
        add_listener(client)
        send_message(client, message)
        assert_response(client, response)
      end
    end

    context 'room is not empty' do
      let(:client1_id) { '4d3d3d3d' }
      let(:client2_id) { 'tayne' }
      let(:client1_badge) { { name: 'celery man' } }
      let(:client2_badge) { { name: 'enter tain ya' } }
      let(:client1) { { badge: client1_badge, peerId: client1_id } }
      let(:client2) { { badge: client2_badge, peerId: client2_id } }
      let(:client1_info) { { badge: client1_badge, room_id: room_id } }
      let(:client2_info) { { badge: client2_badge, room_id: room_id } }
      let(:response) do
        MultiJson.dump({ type: 'callAccepted',
                         payload: { peers: [client1, client2] } })
      end

      before do
        add_to_storage(client1_id, client1_info)
        add_to_storage(client2_id, client2_info)
      end

      it_should_behave_like 'successful call message'

      it 'sends a callAccepted response with the peers' do
        add_listener(client)
        send_message(client, message)
        assert_response(client, response)
      end
    end

    context 'room id is not specified' do
      let(:payload) { { badge: badge } }
      let(:response) do
        MultiJson.dump({ type: 'callRejected',
                         payload: { error: 'Call must include a roomId.' } })
      end
      
      it 'returns a callRejected response' do
        add_listener(client)
        send_message(client, message)
        assert_response(client, response)
      end
    end
  end
end
