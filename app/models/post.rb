# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :content, length: { in: 1..140 }, allow_blank: true
  # NOTE: Bear in mind that the uniqueness validation by rails doesn't work perfectly.
  #   So don't forget to add the validation on the db level. See: db/migrate/20180228012223_add_id_token_to_posts.rb
  validates :id_token, presence: true, uniqueness: true

  # NOTE: Put logic (block) here because there's only one line. It should be a private method when there're multiple lines.
  before_validation -> { self.id_token = SecureRandom.uuid if id_token.blank? }

  # TODO: Might want to use key value store? (redis?)
  def self.posts_by_following_users(follower)
    joins(user: :followed_relations)
      .includes(:user)
      .where('followings.follower_id = ?', follower.id)
      .order('posts.created_at DESC')
  end
end
