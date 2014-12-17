#--
# Copyright 2010-2014 Jens Hausherr
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#++
require 'prawn'
require 'rqrcode'

# :title: Prawn/QRCode
#
# :main: This is an extension for Prawn::Document to simplify rendering QR Codes.
# The module registers itself as Prawn extension upon loading.
#
# *Author*::    Jens Hausherr  (mailto:jabbrwcky@googlemail.com)
# *Copyright*:: Copyright (c) 2011 Jens Hausherr
# *License*::   Apache License, Version 2.0
#
module QRCode
  # Prints a QR Code to the PDF document. The QR Code creation happens on the fly.
  #
  # Arguments:
  # <tt>content/tt>:: The string to render as content of the QR Code
  #
  # Options:
  # <tt>:options</tt>:: Named optional parameters
  # <tt>:version</tt>:: The QR Code version
  # <tt>:level</tt>:: Error correction level to use. One of: (:l,:m,:h,:q), Defaults to :m
  # <tt>:dot</tt>:: Size of QR Code module/dot.
  # <tt>:at</tt>:: an array [x,y] with the location of the top left corner of the image.
  # <tt>:position</tt>::  One of (:left, :center, :right) or an x-offset
  # <tt>:vposition</tt>::  One of (:top, :center, :center) or an y-offset
  # <tt>:height</tt>:: the height of the image [actual height of the image]
  # <tt>:width</tt>:: the width of the image [actual width of the image]
  # <tt>:scale</tt>:: scale the dimensions of the image proportionally
  # <tt>:fit</tt>:: scale the dimensions of the image proportionally to fit inside [width,height]
  def print_qr_code(content, options = {})
    version = options[:version] || 0
    level = options[:level] || :m

    begin
      version +=1
      qr_code = RQRCode::QRCode.new(content, :size => version, :level=> level)
      render_qr_code(qr_code)
    rescue RQRCode::QRCodeRunTimeError
      if version <40
        retry
      else
        raise
      end
    end
  end

  # Renders a QR Code (RQRCode::QRCode) object.
  #
  # Arguments:
  # <tt>qr_code/tt>:: The QR Code (an RQRCode::QRCode) to render
  #
  # Options:
  # <tt>:options</tt>:: Named optional parameters
  # <tt>:dot</tt>:: Size of QR Code module/dot.
  # <tt>:at</tt>:: an array [x,y] with the location of the top left corner of the image.
  # <tt>:position</tt>::  One of (:left, :center, :right) or an x-offset
  # <tt>:vposition</tt>::  One of (:top, :center, :center) or an y-offset
  # <tt>:height</tt>:: the height of the image [actual height of the image]
  # <tt>:width</tt>:: the width of the image [actual width of the image]
  # <tt>:scale</tt>:: scale the dimensions of the image proportionally
  # <tt>:fit</tt>:: scale the dimensions of the image proportionally to fit inside [width,height]
  def render_qr_code(qr_code, options = {})
    dot_w, dot_h = qrcode_dot_size(qr_code, options)
    if options[:at]
      pos_x, pos_y = options[:at]
    else
      pos_x, pos_y = qrcode_position(qr_code.modules.first.length * dot_w, qr_code.modules.length * dot_h, options)
    end

    qr_code.modules.each do |col|
      temp_x = pos_x
      col.each do |row|
        if row
          fill { rectangle([temp_x, pos_y], dot_w, dot_h) }
        end
        temp_x += dot_w
      end
      pos_y -= dot_h
    end
  end

private
  def qrcode_position(w, h, options = {})
    options[:vposition] ||= :top
    options[:position] ||= :left
    
    y = case options[:vposition]
    when :top
      bounds.top
    when :center
      bounds.top - (bounds.height - h) / 2.0
    when :bottom
      bounds.bottom + h
    when Numeric
      bounds.top - options[:vposition]
    end

    x = case options[:position]
    when :left
      bounds.left
    when :center
      bounds.left + (bounds.width - w)/ 2.0
    when :right
      bounds.right - w
    when Numeric
      options[:position] + bounds.left
    end

    return [x,y]
  end

  def qrcode_dot_size(qr_code, options)
    qr_w = qr_code.modules.length
    qr_h = qr_code.modules.first.length
    w = options[:width] || qr_w
    h = options[:height] || qr_h

    if options[:width] && !options[:height]
      wp = w / qr_w
      w = qr_w * wp
      h = qr_h * wp
    elsif options[:height] && !options[:width]
      hp = h / qr_h
      w = qr_w * hp
      h = qr_h * hp
    elsif options[:scale]
      w = qr_w * options[:scale]
      h = qr_h * options[:scale]
    elsif options[:fit]
      bw, bh = options[:fit]
      bp = bw / bh.to_f
      ip = qr_w / qr_h
      if ip > bp
        w = bw
        h = bw / ip
      else
        h = bh
        w = bh * ip
      end
    end

    [w/qr_w, h/qr_h]
  end

end

Prawn::Document.extensions << QRCode
