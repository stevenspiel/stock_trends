class FavoriteSym < ActiveRecord::Base
  belongs_to :sym
  belongs_to :user
end
