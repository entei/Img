class Image < ActiveRecord::Base
  has_attached_file :img
  attr_accessible :description, :name, :img
  validates :name, :img,  presence: true
end
