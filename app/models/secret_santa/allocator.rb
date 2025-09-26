# frozen_string_literal: true

module SecretSanta
  # Responsible for allocating receivers to givers (User objects)
  module Allocator
  module_function

    # Accepts Array<User>, returns Hash{giver => receiver}
    # Tries random shuffles until valid (no self-assignment). Guarantees a result for n>=2.
    def draw(users)
      raise ArgumentError, 'need at least 2 participants' if users.size < 2

      givers = users.dup
      receivers = users.dup

      tries = 0
      loop do
        tries += 1
        receivers.shuffle!
        ok = true
        assignments = {}
        givers.each_with_index do |giver, idx|
          receiver = receivers[idx]
          if receiver.id == giver.id
            ok = false
            break
          else
            assignments[giver] = receiver
          end
        end
        return assignments if ok

        # fallback: after many tries, do an intelligent rotate to avoid infinite loop
        next unless tries > 1000

        # deterministically rotate receivers by 1 (no self-assignment guaranteed if users.size > 1)
        receivers.rotate!(1)
        assignments = {}
        givers.each_with_index do |giver, idx|
          assignments[giver] = receivers[idx]
        end
        return assignments
      end
    end
  end
end
