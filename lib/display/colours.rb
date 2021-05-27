# frozen-string-literal: true

# Monkey patch the String class to include colours
class String

  def red
    "\e[31m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def cyan
    "\e[36m#{self}\e[0m"
  end

  def yellow
    "\e[33m#{self}\e[0m"
  end

  def yellow226
    "\e[38;5;226m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[0m"
  end

  def italics
    "\e[3m#{self}\e[0m"
  end

  def dim
    "\e[2m#{self}\e[0m"
  end
end
