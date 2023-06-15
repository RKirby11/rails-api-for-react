class Friendship < ApplicationRecord
    belongs_to :requester, class_name: "User"
    belongs_to :responder, class_name: "User"

    validates :requester_id, presence: true
    validates :responder_id, presence: true
    validates :accepted, presence: true, inclusion: { in: [true, false] }
    validate :validate_requester_existence
    validate :validate_responder_existence
    validate :unique_friendship

    private 
        def validate_requester_existence
            errors.add(:requester_id, "does not exist") unless User.exists?(requester_id)
        end
        
        def validate_responder_existence
            errors.add(:responder_id, "does not exist") unless User.exists?(responder_id)
        end

        def unique_friendship
            errors.add(:friendship, "already exists or has been requested") if Friendship.exists?(requester_id: requester_id, responder_id: responder_id) || Friendship.exists?(requester_id: responder_id, responder_id: requester_id)
        end
    
end
