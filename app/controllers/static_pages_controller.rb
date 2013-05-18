class StaticPagesController < ApplicationController

  def home
    @images = Image.all
    @tip = "Select or upload image"
  end

  def contact
    @tip = "Contact us"
  end

  def about
    @tip = "About image filter"
  end

end
