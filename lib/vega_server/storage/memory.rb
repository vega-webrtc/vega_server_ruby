module VegaServer
  module Storage
    class Memory
      ROOMS           = :rooms.freeze
      CLIENT_BADGES   = :client_badges.freeze
      CLIENT_ROOM_IDS = :client_room_ids.freeze

      # rooms : hash of roomIds that point to an array of clients, which contain client id and badge
      # client_badges : hash of clientId => badge pairs
      # client_room_ids : hash of clientId => roomId pairs

      def self.add_to_room(client_id, client_info)
        client_info = client_info.merge(client_id: client_id)
        room_id = client_info.delete(:room_id)

        client_badges[client_id]   = client_info[:badge]
        client_room_ids[client_id] = room_id

        rooms[room_id] ||= []
        rooms[room_id].push(client_info)
      end

      def self.client_room(client_id)
        if room_id = client_room_id(client_id)
          room(room_id)
        else
          []
        end
      end

      def self.remove_client(client_id)
        client_room(client_id).delete_if do |client|
          client[:client_id] == client_id
        end

        if client_room(client_id).empty?
          room_id = client_room_id(client_id)
          rooms.delete(room_id)
        end

        client_room_ids.delete(client_id)
        client_badges.delete(client_id)
      end

      def self.room(room_id)
        rooms[room_id] || []
      end

      def self.badge(client_id)
        client_badges[client_id]
      end

      def self.storage
        @storage ||= {}
      end
      private_class_method :storage

      def self.client_room_id(client_id)
        client_room_ids[client_id]
      end
      private_class_method :client_room_id

      def self.client_badges
        storage[CLIENT_BADGES] ||= {}
      end
      private_class_method :client_badges

      def self.client_room_ids
        storage[CLIENT_ROOM_IDS] ||= {}
      end
      private_class_method :client_room_ids

      def self.rooms
        storage[ROOMS] ||= {}
      end
      private_class_method :rooms
    end
  end
end
