require 'RMagick'
require 'rubygems'

class ImagesController < ApplicationController

  def new
    @image = Image.new
    @tip = "Choice image and fill form"
  end

  def show
    @image = Image.find(params[:id])
    @tip = 'Choice filters'
  end

  def create
    @image = Image.new(params[:img])
    if @image.save
      redirect_to @image
    else
      redirect_to new_image_path
    end
  end


  def adaptive
    path = Image.find(params[:id]).img.path
    im = Magick::Image::read(path)[0]

   #im.border!(5, 5, "blue")
   #im = im.resize(190,190)

    im = im.charcoal(radius=0.0, sigma=1.0)

   # mono = im.quantize(256, Magick::GRAYColorspace)
   # colorized = mono.colorize(0.30, 0.30, 0.30, '#cc9933')

   # If you want to save this image use following
   #im.write("3.jpg")

   # otherwise send it to the browser as follows
    send_data(im.to_blob, :disposition => 'inline',
                       :type => 'image/jpg')
  end

  def conv
    path = Image.find(params[:id]).img.path
    im = Magick::Image::read(path)[0]

    @width = im.columns
    @height = im.rows

    div = 1
    offset = 0
    #'Soft blur'
   # kernel = [[0.0, 0.2,  0.0], [0.2, 0.2,  0.2],[0.0, 0.2,  0.0]]
    #'Negative'
    #kernel =[[0,0,0],[0,-1,0],[0,0,0,]]
    #'Emboss'
    kernel = [[-2.0, -1.0, 0.0],  [-1.0, 1.0, 1.0],  [0.0, 1.0, 2.0]]
    #'Sharpen'
    #kernel = [[-1.0, -1.0, -1.0], [-1.0, 9.0, -1.0], [-1.0, -1.0, -1.0]]
    #'Blur'
    #kernel = [[0.1111,0.1111,0.1111],[0.1111,0.1111,0.1111],[0.1111,0.1111,0.1111]]

    @width.times do |x|
      @height.times do |y|

        x0 = x==0 ? 0 : x-1
        y0 = y==0 ? 0 : y-1
        x1 = x
        y1 = y
        x2 = x+1==@width  ? x : x+1
        y2 = y+1==@height ? y : y+1

        r = g = b = 0
        [x0, x1, x2].zip(kernel).each do  |xx, kcol|
          [y0, y1, y2].zip(kcol).each do |yy, k|
            px = im.pixel_color(xx, yy)

            r += k * (px.red)
            g += k * (px.green)
            b += k * (px.blue)
            #p "r: #{px.red.to_i} g: #{px.green.to_i} b: #{px.blue.to_i}"
          end
        end
        #p "r: #{r.to_i} g: #{g.to_i} b: #{b.to_i}"
       newpix = Magick::Pixel.new((r/div + offset), (g/div + offset), (b/div + offset))
        p newpix
        im.pixel_color(x, y, newpix)
      end
    end
  # im.write('/home/expsk/resultRails.jpg')
    send_data(im.to_blob, :disposition => 'inline',
             :type => 'image/jpg')
  end

  def luma(value)
    if value < 0
      0
    elsif value > 65535
      65535
    else
      value
    end
  end


  def sharpen
   path = Image.find(params[:id]).img.path
   im = Magick::Image::read(path)[0]

  # width, height = 100, 100
   radius = params[:radius].to_i
   sigma = params[:sigma].to_i
  # im = im.resize(width, height)
   im = im.sharpen(radius, sigma)

   send_data(im.to_blob, :disposition => 'inline',
             :type => 'image/jpg')

  end

  def blur
    path = Image.find(params[:id]).img.path
    im = Magick::Image::read(path)[0]

    radius = params[:radius].to_i
    sigma = params[:sigma].to_i

    im = im.blur_image(radius, sigma)
    send_data(im.to_blob, :disposition => 'inline',
              :type => 'image/jpg')
  end
  def polaroid(image)
    image.border!(18, 18, "#f0f0ff")
    # Bend the image
    image.background_color = "none"

    amplitude = image.columns * 0.01        # vary according to taste
    wavelength = image.rows  * 2

    image.rotate!(90)
    image = image.wave(amplitude, wavelength)
    image.rotate!(-90)

# Make the shadow
    shadow = image.flop
    shadow = shadow.colorize(1, 1, 1, "gray75")     # shadow color can vary to taste
    shadow.background_color = "white"       # was "none"
    shadow.border!(10, 10, "white")
    shadow = shadow.blur_image(0, 3)        # shadow blurriness can vary according to taste

# Composite image over shadow. The y-axis adjustment can vary according to taste.
    image = shadow.composite(image, -amplitude/2, 5, Magick::OverCompositeOp)

    image.rotate!(-5)                       # vary according to taste
    image.trim!
    image
  end

  def gray
    path = Image.find(params[:id]).img.path
    img = Magick::Image::read(path)[0]
    pixels = img.get_pixels(0,0,img.columns,img.rows)
    power = params[:power].to_i

    for pixel in pixels
      avg = (pixel.red + pixel.green + pixel.blue) / power
      pixel.red = avg
      pixel.blue = avg
      pixel.green = avg
    end

    img.store_pixels(0,0, img.columns, img.rows, pixels)

    send_data(img.to_blob, :disposition => 'inline',
              :type => 'image/jpg')
  end

  def median
    path = Image.find(params[:id]).img.path
    im = Magick::Image::read(path)[0]
  end

end
