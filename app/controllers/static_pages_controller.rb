class StaticPagesController < ApplicationController

  def home
    @images = Image.all
    @tip = "Select or upload image"
  end

end
